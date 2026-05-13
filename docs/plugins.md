# Plugins

Plugins are optional hooks into Rivet's runtime.

Most games can start without plugins. Use them when you want to observe or
extend Rivet behavior in one place, such as logging Unit startup or watching
network calls.

## Create a Plugin

```lua
local LogPlugin = {}

LogPlugin.Id = "LogPlugin"

function LogPlugin:OnUnitStart(unit)
	print("Started", unit.Id)
end

return LogPlugin
```

## Register It Before Startup

```lua
local LogPlugin = require(script.LogPlugin)

Rivet.Use(LogPlugin)

Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
})
```

Plugin ids must be unique. If a hook errors, Rivet includes the plugin id and
hook name in the error message.

Plugins should stay small. A good plugin watches or augments the runtime; it
should not make Units hard to understand on their own.

## Common Hooks

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

## Hook Order

Plugin lifecycle follows the Rivet lifecycle:

1. plugin `Init`
2. Unit loading and preparation hooks
3. Unit `Init` hooks
4. plugin `Start`
5. Unit `Start` hooks
6. plugin `OnDestroy`

Use `Init` when the plugin needs to set up state before Units run. Use `Start`
when the plugin wants to act after Rivet has finished preparing the runtime.

## Example: Count Started Units

```lua
local CountPlugin = {}

CountPlugin.Id = "CountPlugin"

function CountPlugin:Init()
	self.Count = 0
end

function CountPlugin:OnUnitStart()
	self.Count += 1
end

return CountPlugin
```

Previous: [Codecs](codecs.md)  
Next: [Errors](errors.md)
