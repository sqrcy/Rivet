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

Previous: [Codecs](codecs.md)  
Next: [Errors](errors.md)
