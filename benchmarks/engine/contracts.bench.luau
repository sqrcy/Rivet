--!strict

--[=[
	@class ContractEngineBenchmark

	Standalone scaffold for measuring direct contract validation overhead.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contracts = require(ReplicatedStorage.Rivet.Contracts)

-- Public API

local iterations = 10_000
local startedAt = os.clock()

for index = 1, iterations do
	Contracts.ValidateTuple(
		"BenchmarkUnit",
		"DirectContract",
		"arg",
		{ "string", "number" },
		table.pack("item", index),
		"engine"
	)
end

return {
	Name = "contracts-direct",
	Seconds = os.clock() - startedAt,
	Calls = iterations,
}
