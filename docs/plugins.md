# Plugins

Rivet v1.0 supports optional plugins registered before startup. v1.0 does
**not** include generated types or state systems.

```lua
local LogPlugin = {}
LogPlugin.Id = "LogPlugin"

function LogPlugin:OnUnitStart(unit)
	print("Started", unit.Id)
end

Rivet.Use(LogPlugin)
Rivet.Start({
	Roots = {
		ReplicatedStorage.Units,
	},
})
```

Supported hooks:

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

Plugin ids must be unique. Hook failures include the plugin id and hook name.
