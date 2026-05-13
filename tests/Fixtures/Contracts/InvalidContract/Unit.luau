--!strict

--[=[
	@class InvalidContractFixture

	Test unit with unsupported contract metadata.
]=]

-- Public API

local Unit = {}

Unit.Id = "InvalidContract"
Unit.Surfaces = {
	Client = {
		UseValue = {
			Kind = "Action",
			Args = { "thread" },
		},
	},
}

function Unit.UseValue() end

return Unit
