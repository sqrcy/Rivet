# Networking

Rivet turns declared Client surfaces into Roblox remotes.

The important rule is simple: only declared surfaces are reachable from the
client. Other Unit methods stay private to the server.

This keeps networking close to the Unit that owns the behavior. You declare the
public shape beside the method that handles it.

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

The client call does not pass the `Player`. Roblox already knows which client
sent the request, so Rivet supplies it for the server method.

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

Use Actions for requests where the client can continue immediately. Saving a
setting, equipping an item, or submitting a button press are all natural Action
shapes.

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

Signals go from the server to clients. Server code can fire to one player, every
player, or everyone except one player.

```lua
self.Client.ItemAdded:Fire(player, "Sword")
self.Client.ItemAdded:FireAll("Sword")
self.Client.ItemAdded:FireExcept(player, "Sword")
```

## Client Lookup

Client code uses the same `Rivet.Get` shape:

```lua
local Inventory = Rivet.Get("Inventory")
local items = Inventory:GetItems()
```

On the client, Rivet returns a proxy for declared Client surfaces. The proxy only
contains the surface names the Unit declared.

## Remote Organization

Rivet keeps generated remotes under `ReplicatedStorage.RivetRemotes`, grouped by
Unit id and surface name. Most users do not need to touch these Instances
directly, but the layout is predictable when debugging.

Previous: [Surfaces](surfaces.md)  
Next: [Contracts](contracts.md)
