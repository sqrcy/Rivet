--!strict

--[=[
	@class InvalidMissingSharedFixture

	Test unit with a Shared surface missing its backing method.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidMissingShared"
Unit.Surfaces = {
	Shared = {
		"CanStack",
	},
}

return Unit
