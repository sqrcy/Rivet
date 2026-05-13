--!strict

--[=[
	@class InventoryFixture

	Test unit depending on Data.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Constants

local TestState = require(script.Parent.Parent.Parent.TestState)

-- Public API

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Dependencies = { "Data" }

function Inventory.Init(self: UnitContext)
	TestState.Push("Inventory.Init")

	self.Data = self:Get("Data")
	self.Clean:Add(function()
		TestState.Push("Inventory.Clean")
	end)
end

function Inventory.Start(_self: UnitContext)
	TestState.Push("Inventory.Start")
end

function Inventory.Destroy(_self: UnitContext)
	TestState.Push("Inventory.Destroy")
end

return Inventory
