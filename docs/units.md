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

## What Belongs In a Unit

Use a Unit for behavior that has a lifetime. Good examples are inventory,
profiles, matchmaking, round state, economy, notifications, and other systems
that start once and stay available.

If a ModuleScript is only a helper, keep it as a normal module and require it
from a Unit. Rivet only manages ModuleScripts inside the roots you give it.

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

## Keep Unit Tables Clear

Most Units follow this shape:

```lua
--!strict

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Dependencies = { "Data" }

function Inventory:Init()
	self.Data = self:Get("Data")
	self.Items = {}
end

function Inventory:Start()
	-- begin work after every Unit has initialized
end

return Inventory
```

Put metadata near the top, lifecycle methods after that, and regular methods
after lifecycle methods. This makes the Unit easy to scan when it grows.

Previous: [Getting Started](getting-started.md)  
Next: [Dependencies](dependencies.md)
