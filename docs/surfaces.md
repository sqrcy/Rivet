# Surfaces

Surfaces declare which Unit methods are public across a runtime context.

v1.0 supports Client `Query`, `Action`, and `Signal` surfaces plus Shared
metadata. v1.0 does **not** include generated types or a state system.

```lua
--!strict

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

function Inventory:GetItems(player: Player)
	return {}
end

function Inventory:EquipItem(player: Player, itemId: string)
end

function Inventory:CanStack(itemId: string): boolean
	return true
end

return Inventory
```

Query and Action entries must reference existing Unit methods. Signal entries
create server-side signal helpers and do not require a backing method.
