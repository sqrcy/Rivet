# Dependencies

Units often need each other. For example, `Inventory` may need `Data` before it
can load player items.

Rivet uses explicit dependency ids so startup order is easy to see.

## Declare a Dependency

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

This says: start `Data` before `Inventory`.

## Startup Order

If `Inventory` depends on `Data`, Rivet runs:

1. `Data:Init()`
2. `Inventory:Init()`
3. `Data:Start()`
4. `Inventory:Start()`

All `Init` methods finish before any `Start` method runs.

## Why This Helps

Dependencies make the order visible in the Unit itself. You do not need to rely
on script names, folder order, or hidden require chains.

Previous: [Units](units.md)  
Next: [Lifecycle](lifecycle.md)
