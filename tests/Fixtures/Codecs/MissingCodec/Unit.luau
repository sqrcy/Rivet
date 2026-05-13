--!strict

--[=[
	@class MissingCodecFixture

	Test unit that references an unregistered custom contract.
]=]

-- Public API

local Unit = {}

Unit.Id = "MissingCodecUnit"
Unit.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "GhostItem",
		},
	},
}

function Unit.GetItem()
	return {}
end

return Unit
