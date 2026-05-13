# Clean

`Rivet.Clean` is a small cleanup utility included with the runtime.

v1.0 does **not** include generated types or a state system.

```lua
function Session:Init()
	self.Clean:Add(function()
		print("Session cleaned")
	end)
end
```

Supported tasks:

- functions
- Roblox Instances
- RBXScriptConnections
- tables with `Destroy`, `Disconnect`, or `Cleanup`
- explicit method overrides

`Rivet.Destroy()` calls each Unit's optional `Destroy` method first, then runs
`self.Clean:Cleanup()` in reverse boot order.
