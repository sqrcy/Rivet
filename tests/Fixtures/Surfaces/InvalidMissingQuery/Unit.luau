--!strict

--[=[
	@class InvalidMissingQueryFixture

	Test unit with a Query surface missing its backing method.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidMissingQuery"
Unit.Surfaces = {
	Client = {
		GetItems = "Query",
	},
}

return Unit
