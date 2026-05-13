--!strict

--[=[
	@class ContractsInventoryExample

	Example Unit with primitive runtime contracts.
]=]

-- Public API

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Surfaces = {
	Client = {
		GetItems = {
			Kind = "Query",
			Returns = "table",
		},
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "string" },
		},
	},
}

function Inventory.GetItems()
	return { "Sword" }
end

function Inventory.EquipItem(_self: unknown, player: Player, itemId: string)
	print(player.Name, "equipped", itemId)
end

return Inventory
