--!strict

--[=[
	@class StudioBenchmarkClientRunner

	Runs live Studio client/server remote benchmarks and prints one JSON line.
]=]

-- Types

type SyncInvoke = (sentAt: number, payload: string) -> unknown
type EventFire = (sequence: number, sentAt: number, payload: string) -> ()

type StudioBenchmarkResult = {
	Benchmark: string,
	PayloadBytes: number,
	MeanSeconds: number,
	MedianSeconds: number,
	P50Seconds: number,
	P95Seconds: number,
	P99Seconds: number,
	MinSeconds: number,
	MaxSeconds: number,
	Drops: number,
	Iterations: number,
	Warmups: number,
	Notes: string,
}

type StudioBenchmarkReport = {
	SchemaVersion: number,
	Category: string,
	Environment: {
		Runner: string,
		ClientCount: number,
		Iterations: number,
		Warmups: number,
		TimeoutSeconds: number,
		PayloadSizes: { number },
	},
	Results: { StudioBenchmarkResult },
}

type SignalProxy = {
	Connect: (self: SignalProxy, callback: (...unknown) -> ()) -> RBXScriptConnection,
}

type BenchProxy = {
	Ping: (self: BenchProxy, sentAt: number, payload: string) -> unknown,
	ActionPing: (self: BenchProxy, sequence: number, sentAt: number, payload: string) -> (),
	Fanout: (self: BenchProxy, sequence: number, sentAt: number, payload: string) -> (),
	ActionEcho: SignalProxy,
	FanoutEcho: SignalProxy,
}

-- Constants

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Benchmarks.Studio.Config)
local Rivet = require(ReplicatedStorage.Rivet)

local progressRemote = ReplicatedStorage:WaitForChild(Config.ProgressRemoteName, 30) :: RemoteEvent

-- Private helpers

local function reportProgress(
	phase: string,
	benchmark: string,
	payloadBytes: number,
	completed: number,
	total: number
)
	progressRemote:FireServer(phase, benchmark, payloadBytes, completed, total)
end

local function makePayload(size: number): string
	return string.rep("x", size)
end

local function mean(values: { number }): number
	local total = 0

	for _, value in ipairs(values) do
		total += value
	end

	return total / math.max(#values, 1)
end

local function percentile(sortedValues: { number }, percent: number): number
	local count = #sortedValues

	if count == 0 then
		return 0
	end

	local index = math.clamp(math.ceil(count * percent), 1, count)

	return sortedValues[index]
end

local function summarize(
	benchmark: string,
	payloadBytes: number,
	samples: { number },
	drops: number,
	notes: string
): StudioBenchmarkResult
	local sorted = table.clone(samples)

	table.sort(sorted)

	local minValue = sorted[1] or 0
	local maxValue = sorted[#sorted] or 0
	local average = mean(sorted)

	return {
		Benchmark = benchmark,
		PayloadBytes = payloadBytes,
		MeanSeconds = average,
		MedianSeconds = percentile(sorted, 0.5),
		P50Seconds = percentile(sorted, 0.5),
		P95Seconds = percentile(sorted, 0.95),
		P99Seconds = percentile(sorted, 0.99),
		MinSeconds = minValue,
		MaxSeconds = maxValue,
		Drops = drops,
		Iterations = Config.Iterations,
		Warmups = Config.Warmups,
		Notes = notes,
	}
end

local function runSyncBenchmark(
	benchmark: string,
	payloadBytes: number,
	notes: string,
	invoke: SyncInvoke
): StudioBenchmarkResult
	local payload = makePayload(payloadBytes)
	local drops = 0
	local samples: { number } = {}
	local total = Config.Warmups + Config.Iterations

	reportProgress("start", benchmark, payloadBytes, 0, total)

	for index = 1, Config.Warmups do
		invoke(os.clock(), payload)

		if index == Config.Warmups then
			reportProgress("warmup", benchmark, payloadBytes, index, total)
		end
	end

	for index = 1, Config.Iterations do
		local sentAt = os.clock()
		local success = pcall(function()
			invoke(sentAt, payload)
		end)

		if success then
			samples[index - drops] = os.clock() - sentAt
		else
			drops += 1
		end

		if index % 100 == 0 or index == Config.Iterations then
			reportProgress("measure", benchmark, payloadBytes, Config.Warmups + index, total)
		end
	end

	reportProgress("finish", benchmark, payloadBytes, total, total)

	return summarize(benchmark, payloadBytes, samples, drops, notes)
end

local function runEventBenchmark(
	benchmark: string,
	payloadBytes: number,
	notes: string,
	connect: (
		(number, number, number, number) -> ()
	) -> RBXScriptConnection,
	fire: EventFire
): StudioBenchmarkResult
	local payload = makePayload(payloadBytes)
	local drops = 0
	local samples: { number } = {}
	local expectedSequence = 0
	local receivedAt: number? = nil
	local total = Config.Warmups + Config.Iterations

	reportProgress("start", benchmark, payloadBytes, 0, total)

	local connection = connect(
		function(sequence: number, _sentAt: number, _serverAt: number, _bytes: number)
			if sequence == expectedSequence then
				receivedAt = os.clock()
			end
		end
	)

	local function fireAndWait(sequence: number, shouldRecord: boolean)
		expectedSequence = sequence
		receivedAt = nil

		local sentAt = os.clock()
		fire(sequence, sentAt, payload)

		local deadline = sentAt + Config.TimeoutSeconds

		while receivedAt == nil and os.clock() < deadline do
			task.wait()
		end

		if not shouldRecord then
			return
		end

		if receivedAt == nil then
			drops += 1
			return
		end

		samples[#samples + 1] = (receivedAt :: number) - sentAt
	end

	for index = 1, Config.Warmups do
		fireAndWait(-index, false)

		if index == Config.Warmups then
			reportProgress("warmup", benchmark, payloadBytes, index, total)
		end
	end

	for index = 1, Config.Iterations do
		fireAndWait(index, true)

		if index % 100 == 0 or index == Config.Iterations then
			reportProgress("measure", benchmark, payloadBytes, Config.Warmups + index, total)
		end
	end

	connection:Disconnect()
	reportProgress("finish", benchmark, payloadBytes, total, total)

	return summarize(benchmark, payloadBytes, samples, drops, notes)
end

-- Public API

local nativeRemoteFunction =
	ReplicatedStorage:WaitForChild("NativeRemoteFunctionBench", 30) :: RemoteFunction
local nativeRemoteEvent =
	ReplicatedStorage:WaitForChild("NativeRemoteEventBench", 30) :: RemoteEvent

local remoteRoot = ReplicatedStorage:WaitForChild("RivetRemotes", 30)
remoteRoot:WaitForChild("Bench", 30)

Rivet.Start({
	Roots = {},
})

local Bench = (Rivet:Get("Bench") :: unknown) :: BenchProxy
local results: { StudioBenchmarkResult } = {}

for _, payloadBytes in ipairs(Config.PayloadSizes) do
	results[#results + 1] = runSyncBenchmark(
		"Native RemoteFunction",
		payloadBytes,
		"Native request/response baseline.",
		function(sentAt: number, payload: string)
			return nativeRemoteFunction:InvokeServer(sentAt, payload)
		end
	)

	results[#results + 1] = runSyncBenchmark(
		"Rivet Query",
		payloadBytes,
		"Rivet Query proxy over RemoteFunction.",
		function(sentAt: number, payload: string)
			return Bench:Ping(sentAt, payload)
		end
	)

	results[#results + 1] = runEventBenchmark(
		"Native RemoteEvent echo",
		payloadBytes,
		"Native RemoteEvent client-to-server-to-client echo.",
		function(callback)
			return nativeRemoteEvent.OnClientEvent:Connect(callback)
		end,
		function(sequence: number, sentAt: number, payload: string)
			nativeRemoteEvent:FireServer(sequence, sentAt, payload)
		end
	)

	results[#results + 1] = runEventBenchmark(
		"Rivet Action echo",
		payloadBytes,
		"Rivet Action request echoed through a Rivet Signal.",
		function(callback)
			return Bench.ActionEcho:Connect(
				function(sequence: unknown, sentAt: unknown, serverAt: unknown, bytes: unknown)
					callback(
						sequence :: number,
						sentAt :: number,
						serverAt :: number,
						bytes :: number
					)
				end
			)
		end,
		function(sequence: number, sentAt: number, payload: string)
			Bench:ActionPing(sequence, sentAt, payload)
		end
	)

	results[#results + 1] = runEventBenchmark(
		"Rivet Signal fanout",
		payloadBytes,
		"Rivet server FireAll signal delivery to the benchmark client.",
		function(callback)
			return Bench.FanoutEcho:Connect(
				function(sequence: unknown, sentAt: unknown, serverAt: unknown, bytes: unknown)
					callback(
						sequence :: number,
						sentAt :: number,
						serverAt :: number,
						bytes :: number
					)
				end
			)
		end,
		function(sequence: number, sentAt: number, payload: string)
			Bench:Fanout(sequence, sentAt, payload)
		end
	)
end

local report: StudioBenchmarkReport = {
	SchemaVersion = 1,
	Category = "StudioRemote",
	Environment = {
		Runner = "Rojo-served Studio play session",
		ClientCount = 1,
		Iterations = Config.Iterations,
		Warmups = Config.Warmups,
		TimeoutSeconds = Config.TimeoutSeconds,
		PayloadSizes = Config.PayloadSizes,
	},
	Results = results,
}

print(Config.ResultMarker .. HttpService:JSONEncode(report))
