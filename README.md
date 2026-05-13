# Rivet

Rivet is an all-in-one Roblox/Luau framework package by `@sqrcy`. It lets you
write ordinary ModuleScripts, then adds startup order, cleanup, explicit public
surfaces, networking, contracts, codecs, and plugins around them.

## Install

```toml
[dependencies]
Rivet = "sqrcy/rivet@1.0.1"
```

## Feature Highlights

### Ordinary Units With Managed Boot

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

Rivet dependency-sorts Units, runs every `Init` before any `Start`, gives each
Unit `self:Get(...)`, and destroys everything in reverse boot order. You get
predictable startup without turning your code into a framework-specific builder
API.

### Explicit Surfaces And Networking

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

Queries return values, Actions send one-way requests, and Signals let the server
push events to clients. Rivet creates and organizes the underlying remotes at
runtime, then client code uses normal `Rivet:Get("UnitId")` access.

### Runtime Contracts And Codecs

Contracts validate common runtime values, codecs move custom objects across
network calls, and error messages point at the Unit and surface that failed.

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

Codecs are explicit encoder/decoder pairs for custom objects. They let you move
domain values like items, loadout entries, or profile snapshots through surfaced
network calls without guessing from table shape.

### Built-In Cleanup

Every Unit receives `self.Clean`, a small cleanup helper for functions,
Instances, connections, and objects with `Destroy`, `Disconnect`, or `Cleanup`.

```lua
function Inventory:Start()
	self.Clean:Add(Players.PlayerRemoving:Connect(function(player)
		self.Items[player] = nil
	end))
end
```

Cleanup runs automatically during `Rivet.Destroy()`, after the Unit's own
`Destroy` method.

### Plugins For Runtime Hooks

Plugins can observe and extend Rivet without changing every Unit. Use them for
logging, diagnostics, metrics, or project-specific startup policy.

```lua
local LogPlugin = {}

LogPlugin.Id = "LogPlugin"

function LogPlugin:OnUnitStart(unit)
	print("Started", unit.Id)
end

Rivet.Use(LogPlugin)
```

### Highly Performant Runtime

Rivet keeps the runtime path small and measurable. The current benchmark suite
covers engine/headless framework overhead plus live Roblox remote behavior.

Highlights from the current results:

- Engine/headless Query dispatch: about `8.81 us/op`
- Engine/headless string-contract Query dispatch: about `10.14 us/op`
- Engine/headless small codec Query return: about `12.27 us/op`
- Live Roblox Rivet Query, 1024-byte payload: about `70.38 ms` mean with `0` drops
- Live Roblox Rivet Action echo, 1024-byte payload: about `71.65 ms` mean with `0` drops

See [Benchmark Results](docs/benchmark-results.md) for the full tables,
percentiles, payload sizes, and notes.

## Why Adopt Rivet

Rivet is for Roblox projects that have outgrown loose ModuleScripts but do not
want to give up ordinary Luau.

Use Rivet when you want:

- startup order that is visible in code
- one place to manage lifecycle and cleanup
- networking that only exposes declared surfaces
- optional runtime validation at remote boundaries
- explicit custom-object serialization through codecs
- plugin hooks for project-wide diagnostics
- a package that has no external runtime dependencies

The practical benefit is consistency. Units look like normal modules, remotes
are declared beside the methods they expose, dependencies are sorted before boot,
and cleanup has a single predictable path. That makes the codebase easier to
read, easier to test, and easier to grow.

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
