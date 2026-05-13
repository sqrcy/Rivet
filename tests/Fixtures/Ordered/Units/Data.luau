--!strict

--[=[
	@class DataFixture

	Test unit used to verify Rivet dependency and lifecycle behavior.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Constants

local TestState = require(script.Parent.Parent.Parent.TestState)

-- Public API

local Data = {}

Data.Id = "Data"

function Data.Init(self: UnitContext)
	TestState.Push("Data.Init")

	self.Clean:Add(function()
		TestState.Push("Data.Clean")
	end)
end

function Data.Start(_self: UnitContext)
	TestState.Push("Data.Start")
end

function Data.Destroy(_self: UnitContext)
	TestState.Push("Data.Destroy")
end

return Data
