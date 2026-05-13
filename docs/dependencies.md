# Dependencies

Rivet v1.0 supports explicit Unit dependencies by id.

v1.0 does **not** include generated types or a state system.

```lua
--!strict

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Dependencies = { "Data" }

function Inventory:Init()
	self.Data = self:Get("Data")
end

return Inventory
```

## Ordering

Dependencies initialize and start before dependents.

If `Inventory` depends on `Data`, Rivet runs:

1. `Data:Init()`
2. `Inventory:Init()`
3. `Data:Start()`
4. `Inventory:Start()`

## Errors

Rivet fails startup with clear errors when:

- A dependency id is missing.
- Two Units use the same id.
- Dependencies form a cycle.

Circular dependency errors include the dependency path.
