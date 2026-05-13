--!strict

--[=[
	@class DefaultNamedFixture

	Test unit that relies on its ModuleScript name as its unit id.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Constants

local TestState = require(script.Parent.Parent.Parent.TestState)

-- Public API

local DefaultNamed = {}

function DefaultNamed.Init(_self: UnitContext)
	TestState.Push("DefaultNamed.Init")
end

return DefaultNamed
