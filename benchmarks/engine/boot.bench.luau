--!strict

--[=[
	@class BootBenchmark

	Benchmark scaffold for measuring Rivet Unit boot time in Roblox.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)

-- Public API

local startedAt = os.clock()

Rivet.Start({
	Roots = {
		ReplicatedStorage.Benchmarks.Fixtures.BasicUnits,
	},
})

local elapsed = os.clock() - startedAt

Rivet.Destroy()

return {
	Name = "boot",
	Seconds = elapsed,
}
