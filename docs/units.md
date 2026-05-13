# Units

A Unit is a ModuleScript that returns a table. Rivet v1.0 keeps Units ordinary:
id fields, optional dependencies, optional lifecycle methods, and optional
surface metadata.

v1.0 does **not** include generated types or a state system.

```lua
--!strict

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Dependencies = { "Data" }

function Inventory:Init()
	self.Data = self:Get("Data")
end

function Inventory:Start()
end

return Inventory
```

## Ids

`Id` is optional. If omitted, Rivet uses the ModuleScript name.

Unit ids must be unique across all configured roots. Duplicate ids throw a clear
startup error.

## Runtime Fields

Rivet attaches these fields before `Init` runs:

- `self.Id`
- `self.Dependencies`
- `self.Clean`
- `self:Get(id)`

`self:Get(id)` returns another started Unit context from the same runtime.
