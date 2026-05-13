--!strict

--[=[
	@class StudioBenchmarkServerRuntime

	Starts Rivet once for live Studio remote benchmarks.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)

-- State

local started = false

-- Public API

local ServerRuntime = {}

function ServerRuntime.EnsureStarted()
	if started then
		return
	end

	started = true

	Rivet.Start({
		Roots = {
			ReplicatedStorage.BenchUnits,
		},
	})
end

return ServerRuntime
