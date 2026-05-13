--!strict

--[=[
	@class PassiveUtilityFixture

	A passive module that should not load unless its parent is used as a unit root.
]=]

-- Constants

local TestState = require(script.Parent.Parent.TestState)

TestState.PassiveRequired = true

return {}
