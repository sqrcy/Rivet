--!strict

--[=[
	@class BadReturnContractFixture

	Test unit whose Query return violates its contract.
]=]

-- Public API

local Unit = {}

Unit.Id = "BadReturnContract"
Unit.Surfaces = {
	Client = {
		GetCount = {
			Kind = "Query",
			Returns = "number",
		},
	},
}

function Unit.GetCount()
	return "not a number"
end

return Unit
