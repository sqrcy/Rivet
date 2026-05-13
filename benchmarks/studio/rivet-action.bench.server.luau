--!strict

--[=[
	@class RivetActionStudioBenchmark

	Starts the Rivet benchmark Unit for Action and Signal measurements.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerRuntime = require(ReplicatedStorage.Benchmarks.Studio.ServerRuntime)

-- Public API

ServerRuntime.EnsureStarted()
