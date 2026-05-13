--!strict

--[=[
	@class NetworkingInventoryExample

	Example Unit with Query, Action, and Signal surfaces.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

type ClientSignals = {
	ItemAdded: {
		Fire: (self: unknown, player: Player, itemId: string) -> (),
	},
}

-- Public API

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Surfaces = {
	Client = {
		GetItems = "Query",
		EquipItem = "Action",
		ItemAdded = "Signal",
	},
}

function Inventory.GetItems(_self: unknown, _player: Player)
	return { "Sword" }
end

function Inventory.EquipItem(self: UnitContext, player: Player, itemId: string)
	print(player.Name, "equipped", itemId)

	local client = (self.Client :: unknown) :: ClientSignals

	client.ItemAdded:Fire(player, itemId)
end

return Inventory
