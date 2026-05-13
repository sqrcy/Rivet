# Getting Started

Rivet starts with one simple idea: put related game behavior into ModuleScripts,
then let Rivet start those modules in a predictable order.

In Rivet, those managed ModuleScripts are called **Units**.

## 1. Create a Unit Folder

Put your Units in a folder, for example:

```text
ReplicatedStorage
  Units
    Inventory
    Data
```

Each Unit is a ModuleScript that returns a table.

## 2. Start Rivet

Require Rivet, then pass the folder to `Rivet.Start`.

```lua
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Packages.Rivet)

Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
})
```

`Roots` is the list of places Rivet should search for Unit ModuleScripts.

## 3. Get a Unit

After startup, use `Rivet.Get` or `Rivet:Get` to access a Unit by id.

```lua
local Inventory = Rivet.Get("Inventory")
```

Rivet uses `Unit.Id` when it exists. If a Unit does not set `Id`, Rivet uses the
ModuleScript name.

## 4. Add a Second Unit

Rivet becomes more useful when Units can ask for each other.

```lua
--!strict

local Data = {}

Data.Id = "Data"

function Data:Init()
	self.Profiles = {}
end

return Data
```

Then `Inventory` can depend on it:

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

This reads almost like plain Luau because it is plain Luau. The extra metadata
only tells Rivet what order to use and what names to make available.

## 5. Shut Rivet Down

When the runtime ends, call:

```lua
Rivet.Destroy()
```

Rivet destroys Units in the reverse order they started. This keeps dependencies
alive while the Units that use them are cleaning up.

## What To Remember

- Put managed ModuleScripts under the roots you pass to `Rivet.Start`.
- Use `Id` when you want a stable public name.
- Use `Dependencies` when one Unit needs another.
- Use `Rivet.Get` after startup to retrieve a Unit by id.
- Use `Rivet.Destroy` when you want Rivet to run Unit shutdown and cleanup.

Previous: [Docs Index](index.md)  
Next: [Units](units.md)
