--!strict

--[=[
	@class CleanupBenchmark

	Benchmark scaffold for Rivet.Clean task cleanup overhead.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)

-- Public API

local clean = Rivet.Clean.new()

for _index = 1, 1_000 do
	clean:Add(function() end)
end

local startedAt = os.clock()

clean:Cleanup()

return {
	Name = "cleanup",
	Seconds = os.clock() - startedAt,
	Tasks = 1_000,
}
