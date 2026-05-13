# Clean

`Clean` is Rivet's small built-in cleanup helper.

Every Unit receives `self.Clean`. Add anything that should be cleaned when the
Unit is destroyed.

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

Previous: [Lifecycle](lifecycle.md)  
Next: [Surfaces](surfaces.md)
