--!strict

--[=[
	@class CodecInventoryFixture

	Test unit with custom object codec contracts.
]=]

-- Constants

local TestState = require(script.Parent.Parent.Parent.TestState)
local Item = require(script.Parent.Parent.Item)

-- Public API

local Inventory = {}

Inventory.Id = "CodecInventory"
Inventory.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "Item",
		},
		UseItem = {
			Kind = "Action",
			Args = { "Item" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "Item" },
		},
	},
}

function Inventory.GetItem()
	return Item.new("Sword", 1)
end

function Inventory.UseItem(_self: unknown, _player: Player, item: Item.Item)
	TestState.LastArgs = { item }
	TestState.Push(`CodecInventory.UseItem:{item.Id}`)
end

return Inventory
