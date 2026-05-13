--!strict

--[=[
	@class CodecsInventoryExample

	Example Unit using a custom Item codec contract.
]=]

-- Constants

local Item = require(script.Parent.Parent.Item)

-- Public API

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "Item",
		},
	},
}

function Inventory.GetItem()
	return Item.new("Sword", 1)
end

return Inventory
