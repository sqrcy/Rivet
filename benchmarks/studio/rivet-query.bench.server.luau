--!strict

--[=[
	@class RivetQueryStudioBenchmark

	Starts the Rivet benchmark Unit for Query measurements.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerRuntime = require(ReplicatedStorage.Benchmarks.Studio.ServerRuntime)

-- Public API

ServerRuntime.EnsureStarted()
