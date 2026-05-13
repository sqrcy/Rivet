# Getting Started

Rivet v1.0 starts a set of Unit ModuleScripts from configured Roblox Instance
roots, then optionally exposes declared Client surfaces over Roblox remotes.

v1.0 does **not** include generated types or a state system.

## Start Rivet

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

`Roots` must be an array of Roblox Instances. Rivet loads ModuleScripts under
those roots as Units.

## Access Units

```lua
local Inventory = Rivet:Get("Inventory")
```

`Rivet:Get` is available after `Rivet.Start` completes.

## Enable Network Debug Stats

```lua
Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
	Debug = {
		Network = true,
	},
})

local stats = Rivet.Debug:GetNetworkStats()
```

Network debug stats are disabled by default.

## Shut Down

```lua
Rivet.Destroy()
```

Destroy runs in reverse boot order. For each Unit, Rivet calls the optional
`Destroy` method first, then cleans `self.Clean`.
