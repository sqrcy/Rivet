# Units

A Unit is the main building block in Rivet.

Think of a Unit as a normal ModuleScript that Rivet knows how to manage. You do
not need a builder API or a special class system. Return a table, add a few
fields when you need them, and Rivet handles the runtime work.

## A Small Unit

```lua
--!strict

local Inventory = {}

Inventory.Id = "Inventory"

function Inventory:Init()
	self.Items = {}
end

function Inventory:Start()
	print("Inventory is ready")
end

return Inventory
```

## What Rivet Adds

Before `Init` runs, Rivet attaches a few useful runtime fields:

- `self.Id`
- `self.Dependencies`
- `self.Surfaces`
- `self.Clean`
- `self:Get(id)`

The table is still your table. Rivet does not hide it behind a framework object.

## Unit Ids

`Id` is the name Rivet uses to find the Unit later.

```lua
Inventory.Id = "Inventory"
```

If you leave it out, Rivet uses the ModuleScript name.

```lua
-- ModuleScript named Inventory
local Inventory = {}

return Inventory
```

Both examples can be accessed with:

```lua
local Inventory = Rivet.Get("Inventory")
```

Previous: [Getting Started](getting-started.md)  
Next: [Dependencies](dependencies.md)
