--!strict

--[=[
	@class InvalidUnknownKindFixture

	Test unit with an unsupported surface kind.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidUnknownKind"
Unit.Surfaces = {
	Client = {
		GetItems = "Stream",
	},
}

function Unit.GetItems()
	return {}
end

return Unit
