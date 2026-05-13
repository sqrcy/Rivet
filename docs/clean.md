# Clean

`Clean` is Rivet's small built-in cleanup helper.

Every Unit receives `self.Clean`. Add anything that should be cleaned when the
Unit is destroyed.

Think of it as a list of promises to undo work later. If a Unit connects an
event, creates an Instance, or starts holding an object with a cleanup method,
add it to `Clean` near the place where you created it.

## Add a Function

```lua
function Session:Init()
	self.Clean:Add(function()
		print("Session cleaned")
	end)
end
```

## Add Roblox Objects

`Clean` understands common Roblox cleanup shapes:

- functions
- Instances
- RBXScriptConnections
- tables with `Destroy`
- tables with `Disconnect`
- tables with `Cleanup`

```lua
function Session:Init()
	local connection = Players.PlayerRemoving:Connect(function(player)
		print(player.Name, "left")
	end)

self.Clean:Add(connection)
end
```

When the Unit is destroyed, Rivet calls `self.Clean:Cleanup()` after the Unit's
own `Destroy` method runs.

## Remove a Task

Use `Remove` when you want to stop tracking something without cleaning it.

```lua
self.Clean:Remove(connection)
```

## Manual Cleanup

You can call cleanup yourself:

```lua
self.Clean:Cleanup()
```

`Destroy` is an alias:

```lua
self.Clean:Destroy()
```

## Explicit Cleanup Method

If an object has more than one possible cleanup method, pass the one you want.

```lua
self.Clean:Add(resource, "Close")
```

That tells `Clean` to call `resource:Close()` during cleanup.

## Cleanup Order

Tasks are cleaned in reverse add order. The last thing you add is the first thing
that gets cleaned. This mirrors how setup usually works: later setup often
depends on earlier setup.

Previous: [Lifecycle](lifecycle.md)  
Next: [Surfaces](surfaces.md)
