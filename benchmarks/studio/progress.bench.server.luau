--!strict

--[=[
	@class StudioBenchmarkProgressServer

	Server-side progress logger for live Studio benchmark runs.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Benchmarks.Studio.Config)

-- Public API

local existing = ReplicatedStorage:FindFirstChild(Config.ProgressRemoteName)

if existing ~= nil then
	existing:Destroy()
end

local remote = Instance.new("RemoteEvent")
remote.Name = Config.ProgressRemoteName
remote.Parent = ReplicatedStorage

remote.OnServerEvent:Connect(
	function(
		player: Player,
		phase: string,
		benchmark: string,
		payloadBytes: number,
		completed: number,
		total: number
	)
		print(
			`{Config.ProgressMarker} player={player.Name} phase={phase} benchmark="{benchmark}" payloadBytes={payloadBytes} completed={completed}/{total}`
		)
	end
)
