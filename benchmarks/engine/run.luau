--!strict

--[=[
	@class EngineBenchmarkRunner

	Roblox entrypoint for Rivet benchmark runs.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)

type ScenarioResult = {
	Id: string,
	Name: string,
	Category: string,
	Iterations: number,
	Samples: { number },
	MeanSeconds: number,
	MedianSeconds: number,
	MinSeconds: number,
	MaxSeconds: number,
	StdDevSeconds: number,
	OpsPerSecond: number,
	Checksum: number,
	Notes: string,
}

type Scenario = {
	Id: string,
	Name: string,
	Category: string,
	Iterations: number,
	Notes: string,
	Run: () -> (),
}

type BenchmarkItem = {
	Id: string,
	Count: number,
	Tags: { string },
}

type BenchmarkComplex = {
	Id: string,
	Owner: string,
	Version: number,
	Items: { BenchmarkItem },
	Stats: { [string]: number },
	Flags: { [string]: boolean },
	Trace: { { Step: string, Weight: number } },
}

-- Constants

local HttpService = game:GetService("HttpService")
local Rivet = require(ReplicatedStorage.Rivet)
local Network = require(ReplicatedStorage.Rivet.Network)
local Payloads = require(ReplicatedStorage.Benchmarks.Fixtures.Payloads)
local State = require(ReplicatedStorage.Benchmarks.Fixtures.State)

local BENCHMARK_MARKER = "RIVET_BENCHMARK_JSON:"

-- Private helpers

local function globalNumber(name: string, fallback: number): number
	-- selene: allow(global_usage)
	local globals = _G :: Internal.DynamicTable
	local value = globals[name]

	if type(value) == "number" then
		return value
	end

	if type(value) == "string" then
		local parsed = tonumber(value)

		if parsed ~= nil then
			return parsed
		end
	end

	return fallback
end

local function fakePlayer(): Player
	return ({
		Name = "BenchmarkPlayer",
	} :: unknown) :: Player
end

local function remote(unitId: string, surfaceName: string): Instance
	local remoteRoot = ReplicatedStorage:FindFirstChild("RivetRemotes")
	assert(remoteRoot ~= nil, "Expected RivetRemotes")

	local unitFolder = remoteRoot:FindFirstChild(unitId)
	assert(unitFolder ~= nil, `Expected remote folder for {unitId}`)

	local found = unitFolder:FindFirstChild(surfaceName)
	assert(found ~= nil, `Expected remote for {unitId}.{surfaceName}`)

	return found
end

local function mean(values: { number }): number
	local total = 0

	for _, value in ipairs(values) do
		total += value
	end

	return total / math.max(#values, 1)
end

local function median(values: { number }): number
	local sorted = table.clone(values)

	table.sort(sorted)

	local count = #sorted

	if count == 0 then
		return 0
	end

	local middle = math.floor((count + 1) / 2)

	if count % 2 == 1 then
		return sorted[middle]
	end

	return (sorted[middle] + sorted[middle + 1]) / 2
end

local function standardDeviation(values: { number }, average: number): number
	if #values < 2 then
		return 0
	end

	local total = 0

	for _, value in ipairs(values) do
		local delta = value - average

		total += delta * delta
	end

	return math.sqrt(total / (#values - 1))
end

local function summarize(scenario: Scenario, samples: { number }): ScenarioResult
	local average = mean(samples)
	local minValue = math.huge
	local maxValue = 0

	for _, value in ipairs(samples) do
		minValue = math.min(minValue, value)
		maxValue = math.max(maxValue, value)
	end

	if minValue == math.huge then
		minValue = 0
	end

	return {
		Id = scenario.Id,
		Name = scenario.Name,
		Category = scenario.Category,
		Iterations = scenario.Iterations,
		Samples = samples,
		MeanSeconds = average,
		MedianSeconds = median(samples),
		MinSeconds = minValue,
		MaxSeconds = maxValue,
		StdDevSeconds = standardDeviation(samples, average),
		OpsPerSecond = if average > 0 then 1 / average else 0,
		Checksum = State.Checksum,
		Notes = scenario.Notes,
	}
end

local function runScenario(
	scenario: Scenario,
	sampleCount: number,
	warmupCount: number
): ScenarioResult
	for _index = 1, warmupCount do
		scenario.Run()
	end

	local samples: { number } = {}

	for sampleIndex = 1, sampleCount do
		local startedAt = os.clock()

		for _index = 1, scenario.Iterations do
			scenario.Run()
		end

		local elapsed = os.clock() - startedAt

		samples[sampleIndex] = elapsed / scenario.Iterations
	end

	return summarize(scenario, samples)
end

local function encodeItem(value: unknown): unknown
	local item = value :: BenchmarkItem

	return {
		Id = item.Id,
		Count = item.Count,
		Tags = table.clone(item.Tags),
	}
end

local function decodeItem(data: unknown): unknown
	local encoded = data :: BenchmarkItem

	return {
		Id = encoded.Id,
		Count = encoded.Count,
		Tags = table.clone(encoded.Tags),
	}
end

local function encodeComplex(value: unknown): unknown
	local payload = value :: BenchmarkComplex
	local items: { unknown } = {}
	local trace: { unknown } = {}

	for index, item in ipairs(payload.Items) do
		items[index] = encodeItem(item)
	end

	for index, entry in ipairs(payload.Trace) do
		trace[index] = {
			Step = entry.Step,
			Weight = entry.Weight,
		}
	end

	return {
		Id = payload.Id,
		Owner = payload.Owner,
		Version = payload.Version,
		Items = items,
		Stats = table.clone(payload.Stats),
		Flags = table.clone(payload.Flags),
		Trace = trace,
	}
end

local function decodeComplex(data: unknown): unknown
	local encoded = data :: Internal.DynamicTable
	local items: { BenchmarkItem } = {}
	local trace: { { Step: string, Weight: number } } = {}

	for index, item in ipairs(encoded.Items :: { unknown }) do
		items[index] = decodeItem(item) :: BenchmarkItem
	end

	for index, entry in ipairs(encoded.Trace :: { Internal.DynamicTable }) do
		trace[index] = {
			Step = entry.Step,
			Weight = entry.Weight,
		}
	end

	return {
		Id = encoded.Id,
		Owner = encoded.Owner,
		Version = encoded.Version,
		Items = items,
		Stats = table.clone(encoded.Stats),
		Flags = table.clone(encoded.Flags),
		Trace = trace,
	}
end

-- Public API

local sampleCount = math.max(globalNumber("RIVET_BENCHMARK_SAMPLES", 7), 1)
local warmupCount = math.max(globalNumber("RIVET_BENCHMARK_WARMUPS", 50), 0)
local baseIterations = math.max(globalNumber("RIVET_BENCHMARK_ITERATIONS", 1_000), 1)
local bootIterations = math.max(globalNumber("RIVET_BENCHMARK_BOOT_ITERATIONS", 50), 1)
local cleanupIterations = math.max(globalNumber("RIVET_BENCHMARK_CLEANUP_ITERATIONS", 100), 1)
local cleanupTasks = math.max(globalNumber("RIVET_BENCHMARK_CLEANUP_TASKS", 1_000), 1)
local codecIterations = math.max(globalNumber("RIVET_BENCHMARK_CODEC_ITERATIONS", 250), 1)
local complexIterations = math.max(globalNumber("RIVET_BENCHMARK_COMPLEX_ITERATIONS", 100), 1)
local complexSize = math.max(globalNumber("RIVET_BENCHMARK_COMPLEX_SIZE", 40), 1)

Rivet.Codec:Register("BenchmarkItem", {
	Encode = encodeItem,
	Decode = decodeItem,
})

Rivet.Codec:Register("BenchmarkComplex", {
	Encode = encodeComplex,
	Decode = decodeComplex,
})

local runtimeScenarios: { Scenario } = {
	{
		Id = "boot-basic-unit",
		Name = "Boot: basic surfaced Unit",
		Category = "Runtime",
		Iterations = bootIterations,
		Notes = "Start and destroy a small Unit root with one declared Query surface.",
		Run = function()
			Rivet.Start({
				Roots = {
					ReplicatedStorage.Benchmarks.Fixtures.BasicUnits,
				},
			})

			Rivet.Get("BasicBenchmarkUnit")
			State.Touch(1)
			Rivet.Destroy()
		end,
	},
	{
		Id = "clean-add-cleanup",
		Name = "Clean: add and cleanup tasks",
		Category = "Runtime",
		Iterations = cleanupIterations,
		Notes = "Create a cleaner, add function tasks, and clean them in reverse order.",
		Run = function()
			local clean = Rivet.Clean.new()

			for index = 1, cleanupTasks do
				clean:Add(function()
					State.Touch(index % 7)
				end)
			end

			clean:Cleanup()
		end,
	},
}

State.Reset()

local results: { ScenarioResult } = {}

for _, scenario in ipairs(runtimeScenarios) do
	results[#results + 1] = runScenario(scenario, sampleCount, warmupCount)
end

Rivet.Start({
	Roots = {
		ReplicatedStorage.Benchmarks.Fixtures.Units,
	},
	Debug = {
		Network = true,
	},
})

local player = fakePlayer()
local queryPing = remote("BenchmarkUnit", "Ping") :: RemoteFunction
local queryEcho = remote("BenchmarkUnit", "EchoString") :: RemoteFunction
local actionString = remote("BenchmarkUnit", "AcceptString") :: RemoteEvent
local signalNumber = remote("BenchmarkUnit", "BroadcastNumber") :: RemoteEvent
local queryItem = remote("BenchmarkUnit", "GetItem") :: RemoteFunction
local actionItem = remote("BenchmarkUnit", "UseItem") :: RemoteEvent
local signalItem = remote("BenchmarkUnit", "BroadcastItem") :: RemoteEvent
local queryComplex = remote("BenchmarkUnit", "GetComplex") :: RemoteFunction
local actionComplex = remote("BenchmarkUnit", "UseComplex") :: RemoteEvent
local signalComplex = remote("BenchmarkUnit", "BroadcastComplex") :: RemoteEvent

local benchmarkUnit = Rivet.Get("BenchmarkUnit")
local signalClient = benchmarkUnit.Client :: Internal.DynamicTable

Network.SetTestSignalSink(signalNumber, function() end)
Network.SetTestSignalSink(signalItem, function() end)
Network.SetTestSignalSink(signalComplex, function() end)

local scenarios: { Scenario } = {
	{
		Id = "query-basic",
		Name = "Query: no contracts",
		Category = "Networking",
		Iterations = baseIterations,
		Notes = "RemoteFunction dispatch through a declared Query surface.",
		Run = function()
			Network.DispatchQueryForTest(queryPing, player)
		end,
	},
	{
		Id = "query-contract-string",
		Name = "Query: string contract",
		Category = "Contracts",
		Iterations = baseIterations,
		Notes = "Client arg validation, server dispatch, return validation.",
		Run = function()
			Network.DispatchQueryForTest(queryEcho, player, "Sword")
		end,
	},
	{
		Id = "action-contract-string",
		Name = "Action: string contract",
		Category = "Contracts",
		Iterations = baseIterations,
		Notes = "RemoteEvent dispatch with primitive arg validation.",
		Run = function()
			Network.DispatchActionForTest(actionString, player, "Sword")
		end,
	},
	{
		Id = "signal-contract-number",
		Name = "Signal: number payload",
		Category = "Contracts",
		Iterations = baseIterations,
		Notes = "Server signal wrapper with primitive payload validation.",
		Run = function()
			signalClient.BroadcastNumber:FireAll(1)
		end,
	},
	{
		Id = "query-codec-item",
		Name = "Query: item codec return",
		Category = "Codecs",
		Iterations = codecIterations,
		Notes = "Server encodes and client decodes a small custom object.",
		Run = function()
			Network.DispatchQueryForTest(queryItem, player)
		end,
	},
	{
		Id = "action-codec-item",
		Name = "Action: item codec arg",
		Category = "Codecs",
		Iterations = codecIterations,
		Notes = "Client encodes and server decodes a small custom object.",
		Run = function()
			Network.DispatchActionForTest(actionItem, player, Payloads.item(State.Checksum + 1))
		end,
	},
	{
		Id = "signal-codec-item",
		Name = "Signal: item codec payload",
		Category = "Codecs",
		Iterations = codecIterations,
		Notes = "Server signal encodes and benchmark sink decodes a small object.",
		Run = function()
			signalClient.BroadcastItem:FireAll(Payloads.item(State.Checksum + 1))
		end,
	},
	{
		Id = "query-codec-complex",
		Name = "Query: complex codec return",
		Category = "Complex Shapes",
		Iterations = complexIterations,
		Notes = "Nested tables, arrays, dictionaries, and repeated object entries.",
		Run = function()
			Network.DispatchQueryForTest(queryComplex, player, complexSize)
		end,
	},
	{
		Id = "action-codec-complex",
		Name = "Action: complex codec arg",
		Category = "Complex Shapes",
		Iterations = complexIterations,
		Notes = "Client encode and server decode for a larger nested payload.",
		Run = function()
			Network.DispatchActionForTest(
				actionComplex,
				player,
				Payloads.complex(State.Checksum + 1, complexSize)
			)
		end,
	},
	{
		Id = "signal-codec-complex",
		Name = "Signal: complex codec payload",
		Category = "Complex Shapes",
		Iterations = complexIterations,
		Notes = "Signal payload encode/decode path for a larger nested payload.",
		Run = function()
			signalClient.BroadcastComplex:FireAll(Payloads.complex(State.Checksum + 1, complexSize))
		end,
	},
}

for _, scenario in ipairs(scenarios) do
	results[#results + 1] = runScenario(scenario, sampleCount, warmupCount)
end

local stats = Rivet.Debug:GetNetworkStats()

Rivet.Destroy()

local report = {
	SchemaVersion = 1,
	GeneratedAtUnix = os.time(),
	Config = {
		Samples = sampleCount,
		Warmups = warmupCount,
		BaseIterations = baseIterations,
		BootIterations = bootIterations,
		CleanupIterations = cleanupIterations,
		CleanupTasks = cleanupTasks,
		CodecIterations = codecIterations,
		ComplexIterations = complexIterations,
		ComplexSize = complexSize,
	},
	Environment = {
		Runner = "Roblox Open Cloud Luau Execution",
	},
	Scenarios = results,
	NetworkStats = stats,
}

local encoded = HttpService:JSONEncode(report)

print(BENCHMARK_MARKER .. encoded)

return report
