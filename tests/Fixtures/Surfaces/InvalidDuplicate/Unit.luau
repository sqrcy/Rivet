--!strict

--[=[
	@class InvalidDuplicateSurfaceFixture

	Test unit with colliding Client and Shared surface names.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidDuplicateSurface"
Unit.Surfaces = {
	Client = {
		CanStack = "Query",
	},
	Shared = {
		"CanStack",
	},
}

function Unit.CanStack()
	return true
end

return Unit
