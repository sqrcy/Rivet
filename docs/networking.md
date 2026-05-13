# Networking

Rivet v1.0 includes basic Client surface networking. v1.0 does **not** include
codecs, plugins, generated types, or state systems.

On the server, declared Client surfaces create remotes under
`ReplicatedStorage.RivetRemotes`. Query and Action calls dispatch only to
declared Unit methods. Query and Action server methods receive the requesting
`Player` as the first argument after `self`.

```lua
function Inventory:GetItems(player: Player)
	return {}
end

function Inventory:EquipItem(player: Player, itemId: string)
end
```

Signals are fired from the server through `self.Client`.

```lua
function Inventory:Start()
	self.Client.ItemAdded:FireAll("Sword")
end
```

On the client, `Rivet:Get("Inventory")` returns a proxy exposing only declared
Client surfaces.

```lua
local Inventory = Rivet:Get("Inventory")

local items = Inventory:GetItems()
Inventory:EquipItem("Sword")
Inventory.ItemAdded:Connect(function(itemId: string)
	print(itemId)
end)
```
