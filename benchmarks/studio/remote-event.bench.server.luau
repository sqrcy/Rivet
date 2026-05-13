--!strict

--[=[
	@class NativeRemoteEventStudioBenchmark

	Server endpoint for native RemoteEvent echo benchmarks.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "NativeRemoteEventBench"

-- Public API

local existing = ReplicatedStorage:FindFirstChild(REMOTE_NAME)

if existing ~= nil then
	existing:Destroy()
end

local remote = Instance.new("RemoteEvent")
remote.Name = REMOTE_NAME
remote.Parent = ReplicatedStorage

remote.OnServerEvent:Connect(
	function(player: Player, sequence: number, sentAt: number, payload: string)
		remote:FireClient(player, sequence, sentAt, os.clock(), #payload)
	end
)
