--!strict

--[=[
	@class InvalidMissingActionFixture

	Test unit with an Action surface missing its backing method.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidMissingAction"
Unit.Surfaces = {
	Client = {
		EquipItem = "Action",
	},
}

return Unit
