--!strict

--[=[
	@class BasicBenchmarkUnit

	Small Unit used by single-purpose benchmark scaffolds.
]=]

-- Public API

local BasicBenchmarkUnit = {}

BasicBenchmarkUnit.Id = "BasicBenchmarkUnit"
BasicBenchmarkUnit.Surfaces = {
	Client = {
		Ping = "Query",
	},
}

function BasicBenchmarkUnit.Ping(_self: unknown, _player: Player): number
	return 1
end

return BasicBenchmarkUnit
