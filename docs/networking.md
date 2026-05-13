# Networking

Rivet turns declared Client surfaces into Roblox remotes.

The important rule is simple: only declared surfaces are reachable from the
client. Other Unit methods stay private to the server.

## Query

A Query asks the server for a value.

```lua
Inventory.Surfaces = {
	Client = {
		GetItems = "Query",
	},
}

function Inventory:GetItems(player: Player)
	return { "Sword" }
end
```

Client code can call:

```lua
local Inventory = Rivet.Get("Inventory")
local items = Inventory:GetItems()
```

On the server, Rivet passes the requesting `Player` as the first argument after
`self`.

## Action

An Action tells the server to do something and does not wait for a return value.

```lua
Inventory.Surfaces = {
	Client = {
		EquipItem = "Action",
	},
}

function Inventory:EquipItem(player: Player, itemId: string)
	print(player.Name, "equipped", itemId)
end
```

Client code can call:

```lua
Inventory:EquipItem("Sword")
```

## Signal

A Signal lets the server notify clients.

```lua
Inventory.Surfaces = {
	Client = {
		ItemAdded = "Signal",
	},
}
```

Server code can fire:

```lua
self.Client.ItemAdded:FireAll("Sword")
```

Client code can listen:

```lua
Inventory.ItemAdded:Connect(function(itemId: string)
	print(itemId)
end)
```

Previous: [Surfaces](surfaces.md)  
Next: [Contracts](contracts.md)
