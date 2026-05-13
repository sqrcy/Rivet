# Lifecycle

Rivet gives every managed Unit a simple lifecycle:

1. prepare
2. `Init`
3. `Start`
4. `Destroy`

## Prepare

Prepare is Rivet's internal setup step. This is when Rivet attaches fields like
`self.Clean` and `self:Get`.

You do not write a prepare method.

By the time your lifecycle methods run, the Unit table already has the Rivet
runtime helpers attached.

## Init

Use `Init` to connect dependencies and set up internal state.

```lua
function Inventory:Init()
	self.Data = self:Get("Data")
	self.Items = {}
end
```

`Init` is the best place to read other Units because dependencies are already
prepared.

Use `Init` for:

- saving dependency references
- creating tables and private state
- registering cleanup tasks
- validating setup that must happen before work starts

## Start

Use `Start` when the Unit is ready to do work.

```lua
function Inventory:Start()
	print("Inventory started")
end
```

Rivet waits until every Unit has finished `Init` before it calls any `Start`
method.

Use `Start` for:

- connecting gameplay flow
- starting loops or timers
- firing initial signals
- beginning work that expects all Units to exist

## Destroy

Use `Destroy` for custom shutdown behavior.

```lua
function Inventory:Destroy()
	print("Inventory stopping")
end
```

After `Destroy`, Rivet also cleans `self.Clean`.

Destroy runs in reverse boot order. If `Inventory` depends on `Data`, then
`Inventory` shuts down before `Data`. That lets `Inventory` finish its cleanup
while `Data` is still available.

## A Full Lifecycle Example

```lua
function Inventory:Init()
	self.Data = self:Get("Data")
	self.ItemsByPlayer = {}
end

function Inventory:Start()
	self.Clean:Add(Players.PlayerRemoving:Connect(function(player)
		self.ItemsByPlayer[player] = nil
	end))
end

function Inventory:Destroy()
	table.clear(self.ItemsByPlayer)
end
```

Previous: [Dependencies](dependencies.md)  
Next: [Clean](clean.md)
