# Rivet

Rivet is an all-in-one Roblox/Luau framework package authored by @sqrcy.

This repository currently implements **Rivet v1.0**: managed Units,
dependencies, dependency-sorted lifecycle, cleanup, explicit Surfaces, basic
Query/Action/Signal networking, optional runtime contracts, network debug
stats, explicit codecs, object encode/decode, plugin hooks, and runtime lookup.

v1.0 does **not** include generated types or a state system.

## Install

```toml
[dependencies]
Rivet = "sqrcy/rivet@1.0.0"
```

## Unit Example

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

Inventory.Surfaces = {
	Client = {
		GetItems = {
			Kind = "Query",
			Returns = "table",
		},
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "string" },
		},
	},
}

return Inventory
```

## Boot Example

```lua
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Packages.Rivet)

Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
})

local Inventory = Rivet:Get("Inventory")
```

## Public API

- `Rivet.Start(config)` starts the framework.
- `Rivet.Get(id)` and `Rivet:Get(id)` return a started Unit.
- `Rivet.Destroy()` destroys Units in reverse boot order.
- `Rivet.Clean.new()` creates a cleanup utility.
- `Rivet.Codec:Register(id, codec)` registers object codecs for custom
  contracts.
- `Rivet.Use(plugin)` registers optional plugins before startup.
- `Rivet.Debug:GetNetworkStats()` returns network counters when enabled.

## Testing

Local checks use Wally, Rojo, luau-lsp, Selene, and StyLua.

Roblox engine tests run headlessly through Open Cloud Luau Execution:

```sh
scripts/test-cloud.sh
```

Use a dedicated disposable test universe/place. The command uploads the latest
test place, runs `tests/RunTests.luau`, prints TestEZ logs, and exits non-zero
on failure. See [Cloud Testing](docs/cloud-testing.md).

## Documentation

- [Getting Started](docs/getting-started.md)
- [Units](docs/units.md)
- [Dependencies](docs/dependencies.md)
- [Lifecycle](docs/lifecycle.md)
- [Clean](docs/clean.md)
- [Surfaces](docs/surfaces.md)
- [Networking](docs/networking.md)
- [Contracts](docs/contracts.md)
- [Codecs](docs/codecs.md)
- [Plugins](docs/plugins.md)
- [Errors](docs/errors.md)
- [Testing](docs/testing.md)
- [Benchmarks](docs/benchmarks.md)
- [Versioning](docs/versioning.md)

## License

Rivet is licensed under BSD-3-Clause.
