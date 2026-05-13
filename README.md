# Rivet

Rivet is an all-in-one Roblox/Luau framework package by `@sqrcy`. It lets you
write ordinary ModuleScripts, then adds startup order, cleanup, explicit public
surfaces, networking, contracts, codecs, and plugins around them.

## Install

```toml
[dependencies]
Rivet = "sqrcy/rivet@1.0.0"
```

## Feature Highlights

### Ordinary Units

Rivet Units are just Lua tables returned from ModuleScripts. Add an `Id`,
optional `Dependencies`, and lifecycle methods when you want Rivet to manage
startup and shutdown.

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

### Explicit Surfaces

Surfaces describe the methods a Unit chooses to expose. Query, Action, and
Signal surfaces become predictable Roblox remotes without exposing the rest of
the Unit.

```lua
Inventory.Surfaces = {
	Client = {
		GetItems = "Query",
		EquipItem = "Action",
		ItemAdded = "Signal",
	},
}
```

### Safer Runtime Boundaries

Contracts validate common runtime values, codecs move custom objects across
network calls, and `Clean` gives each Unit a small built-in cleanup utility.

```lua
Inventory.Surfaces = {
	Client = {
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
	},
}
```

## Package

Rivet is a Wally package named `sqrcy/rivet`. The plain package contains the
runtime source, package metadata, project mapping, changelog, readme, and
BSD-3-Clause license. Tests, examples, scripts, docs, and local tooling files are
excluded from the published package.

## License

Rivet is licensed under BSD-3-Clause.

## Documentation

Start with [Docs Index](docs/index.md), then use [API Reference](docs/api-reference.md)
once you know the main ideas.

Benchmarks are a separate reference path covering engine/headless overhead and
live Studio remote behavior. Start with [Benchmarks](docs/benchmarks.md), then
read the current [Benchmark Results](docs/benchmark-results.md).
