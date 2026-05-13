--!strict

--[=[
	@class ContractInventoryFixture

	Test unit with v0.3 runtime contracts.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Constants

local TestState = require(script.Parent.Parent.Parent.TestState)

-- Public API

local Inventory = {}

Inventory.Id = "ContractInventory"
Inventory.Surfaces = {
	Client = {
		GetItems = {
			Kind = "Query",
			Args = { "string" },
			Returns = "table",
		},
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
		AnyValue = {
			Kind = "Action",
			Args = { "any" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "string", "number" },
		},
	},
}

function Inventory.GetItems(_self: UnitContext, player: Player, category: string)
	TestState.LastPlayer = player
	TestState.LastArgs = { category }

	return { category, "Sword" }
end

function Inventory.EquipItem(_self: UnitContext, player: Player, itemId: string)
	TestState.LastPlayer = player
	TestState.LastArgs = { itemId }
	TestState.Push("ContractInventory.EquipItem")
end

function Inventory.AnyValue(_self: UnitContext, _player: Player, value: unknown)
	TestState.LastArgs = { value }
	TestState.Push("ContractInventory.AnyValue")
end

return Inventory
