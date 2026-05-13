# Surfaces

Surfaces are how a Unit says, "these are the parts of me that are public."

Without surfaces, a Unit is still useful locally. With surfaces, Rivet can build
safe runtime access around specific methods and signals.

## Client Surfaces

Client surfaces are available to client code through Rivet proxies.

```lua
Inventory.Surfaces = {
	Client = {
		GetItems = "Query",
		EquipItem = "Action",
		ItemAdded = "Signal",
	},
}
```

There are three Client surface kinds:

- `Query`: the client asks the server for a result.
- `Action`: the client tells the server to do something.
- `Signal`: the server sends an event to clients.

## Shared Surfaces

Shared surfaces are public metadata for ordinary methods.

```lua
Inventory.Surfaces = {
	Shared = {
		"CanStack",
	},
}

function Inventory:CanStack(itemId: string): boolean
	return true
end
```

## Shorthand and Expanded Forms

This shorthand:

```lua
GetItems = "Query"
```

Means the same kind as this expanded form:

```lua
GetItems = {
	Kind = "Query",
}
```

Use the expanded form when you want contracts later.

Previous: [Clean](clean.md)  
Next: [Networking](networking.md)
