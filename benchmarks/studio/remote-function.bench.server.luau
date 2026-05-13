--!strict

--[=[
	@class NativeRemoteFunctionStudioBenchmark

	Server endpoint for native RemoteFunction round-trip benchmarks.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "NativeRemoteFunctionBench"

-- Public API

local existing = ReplicatedStorage:FindFirstChild(REMOTE_NAME)

if existing ~= nil then
	existing:Destroy()
end

local remote = Instance.new("RemoteFunction")
remote.Name = REMOTE_NAME
remote.Parent = ReplicatedStorage

remote.OnServerInvoke = function(_player: Player, sentAt: number, payload: string)
	return {
		SentAt = sentAt,
		ServerAt = os.clock(),
		PayloadBytes = #payload,
	}
end
