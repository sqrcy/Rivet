# API Reference

This page is for quick lookup after you understand the main Rivet ideas.

## Rivet

### `Rivet.Start(config)`

Starts Rivet and loads all Units under `config.Roots`.

```lua
Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
})
```

Config fields:

- `Roots: { Instance }`
- `Debug: { Network: boolean }?`

Behavior:

- safely requires Unit ModuleScripts under `Roots`
- validates ids, dependencies, lifecycle methods, surfaces, contracts, codecs,
  and plugins
- initializes dependencies before dependents
- runs every `Init` before any `Start`
- errors if called while Rivet is already running

### `Rivet.Get(id)`

Returns a started Unit by id.

```lua
local Inventory = Rivet.Get("Inventory")
```

### `Rivet:Get(id)`

Method-call form of `Rivet.Get`.

```lua
local Inventory = Rivet:Get("Inventory")
```

### `Rivet.Destroy()`

Destroys the active runtime. Units are destroyed in reverse boot order.

```lua
Rivet.Destroy()
```

### `Rivet.Use(plugin)`

Registers a plugin before startup.

```lua
Rivet.Use(LogPlugin)
```

### `Rivet.Clean.new()`

Creates a standalone cleaner.

```lua
local clean = Rivet.Clean.new()
```

### `Rivet.Codec:Register(id, codec)`

Registers a codec.

```lua
Rivet.Codec:Register("Item", {
	Encode = function(item)
		return {}
	end,
	Decode = function(data)
		return data
	end,
})
```

Codec shape:

- `Encode(value) -> remoteSafeData`
- `Decode(remoteSafeData) -> value`

Codec ids are strings and must be unique.

### `Rivet.Debug:GetNetworkStats()`

Returns a snapshot of network debug counters when network debug is enabled.

```lua
local stats = Rivet.Debug:GetNetworkStats()
```

Stats shape:

```lua
{
	Inventory = {
		GetItems = {
			Kind = "Query",
			Calls = 12,
			Failures = 0,
		},
	},
}
```

## Unit Fields

### `Unit.Id`

Optional string id. Defaults to the ModuleScript name.

### `Unit.Dependencies`

Optional array of Unit ids that must start first.

```lua
Unit.Dependencies = { "Data" }
```

### `Unit.Surfaces`

Optional public surface declaration.

```lua
Unit.Surfaces = {
	Client = {
		GetItems = "Query",
		EquipItem = "Action",
		ItemAdded = "Signal",
	},
	Shared = {
		"CanStack",
	},
}
```

Expanded Client surface form:

```lua
Unit.Surfaces = {
	Client = {
		GetItems = {
			Kind = "Query",
			Args = { "string" },
			Returns = "table",
		},
	},
}
```

## Unit Lifecycle

### `Unit:Init()`

Runs after Rivet prepares every Unit and before any `Start`.

### `Unit:Start()`

Runs after all `Init` methods finish.

### `Unit:Destroy()`

Runs during `Rivet.Destroy()` before the Unit cleaner is cleaned.

## Runtime Fields

### `self.Clean`

Cleaner attached to each Unit.

### `self:Get(id)`

Gets another Unit from inside a Unit.

### `self.Client`

Server-side signal helpers for Client Signal surfaces.

```lua
self.Client.ItemAdded:Fire(player, item)
self.Client.ItemAdded:FireAll(item)
self.Client.ItemAdded:FireExcept(player, item)
```

## Clean

### `Clean:Add(object, methodName?)`

Adds a cleanup task and returns the same object.

Supported cleanup tasks:

- function
- Instance
- RBXScriptConnection
- table with `Destroy`
- table with `Disconnect`
- table with `Cleanup`
- any object with an explicit method override

### `Clean:Remove(object)`

Stops tracking an object without cleaning it.

### `Clean:Cleanup()`

Cleans all tracked tasks in reverse add order.

### `Clean:Destroy()`

Alias for `Clean:Cleanup()`.

## Surface Kinds

### `Query`

Client asks the server for a return value.

### `Action`

Client sends work to the server without waiting for a return value.

### `Signal`

Server sends an event to clients.

## Contract Fields

### `Args`

Array of expected argument contract names.

### `Returns`

Expected Query return contract name.

### `Payload`

Array of expected Signal payload contract names.

Built-in contract names:

- `nil`
- `boolean`
- `number`
- `string`
- `table`
- `Instance`
- `Player`
- `Vector3`
- `CFrame`
- `Color3`
- `EnumItem`
- `buffer`
- `any`

## Plugin Hooks

- `Init(rivet)`
- `Start(rivet)`
- `OnUnitLoaded(unit)`
- `OnUnitPrepared(unit)`
- `OnUnitInit(unit)`
- `OnUnitStart(unit)`
- `OnSurfaceRegistered(unit, surface)`
- `OnNetworkCall(context)`
- `OnNetworkError(context)`
- `OnDestroy()`

Network hook context fields:

- `UnitId`
- `SurfaceName`
- `Kind`
- `ArgCount` for calls
- `Message` for errors

## Remote Layout

Server remotes are stored under:

```text
ReplicatedStorage
  RivetRemotes
    UnitId
      SurfaceName
```

Query surfaces use `RemoteFunction`. Action and Signal surfaces use
`RemoteEvent`.

Previous: [Errors](errors.md)  
Next: [Packaging](packaging.md)
