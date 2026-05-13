--!strict

--[=[
	@class EncodeFailureCodecFixture

	Test unit whose codec returns an unsupported network value.
]=]

-- Constants

local Item = require(script.Parent.Parent.Item)

-- Public API

local Unit = {}

Unit.Id = "EncodeFailureCodec"
Unit.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "BrokenEncodeItem",
		},
	},
}

function Unit.GetItem()
	return Item.new("Sword", 1)
end

return Unit
