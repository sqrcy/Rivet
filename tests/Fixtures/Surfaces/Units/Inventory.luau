--!strict

--[=[
	@class SurfaceInventoryFixture

	Test unit with v0.2 client and shared surfaces.
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
Inventory.Surfaces = {
	Client = {
		GetItems = "Query",
		EquipItem = {
			Kind = "Action",
		},
		ItemAdded = "Signal",
	},
	Shared = {
		"CanStack",
	},
}

function Inventory.Init(_self: UnitContext)
	TestState.Push("Inventory.Init")
end

function Inventory.GetItems(_self: UnitContext, player: Player, category: string)
	TestState.LastPlayer = player
	TestState.LastArgs = { category }

	return { category, "Sword" }
end

function Inventory.EquipItem(_self: UnitContext, player: Player, itemId: string)
	TestState.LastPlayer = player
	TestState.LastArgs = { itemId }
	TestState.Push("Inventory.EquipItem")
end

function Inventory.CanStack(_self: UnitContext, itemId: string): boolean
	TestState.LastArgs = { itemId }
	return true
end

return Inventory
