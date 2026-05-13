--!strict

--[=[
	@class DecodeFailureCodecFixture

	Test unit whose Action arg codec fails while decoding.
]=]

-- Public API

local Unit = {}

Unit.Id = "DecodeFailureCodec"
Unit.Surfaces = {
	Client = {
		UseItem = {
			Kind = "Action",
			Args = { "BrokenDecodeItem" },
		},
	},
}

function Unit.UseItem() end

return Unit
