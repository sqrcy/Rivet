--!strict

--[=[
	@class SignalOnlyFixture

	Test unit proving Signal surfaces do not require backing methods.
]=]

-- Public API

local Unit = {}

Unit.Id = "SignalOnly"
Unit.Surfaces = {
	Client = {
		ItemAdded = "Signal",
	},
}

return Unit
