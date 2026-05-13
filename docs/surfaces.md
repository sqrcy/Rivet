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

Use Client surfaces for things the client is allowed to ask for or listen to.
Anything left out of `Client` stays server-side.

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

Shared surfaces are useful when the same method name needs to be visible as part
of the Unit's public shape. They do not create remotes by themselves.

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

## Choosing a Kind

Use this quick rule:

- use `Query` when the client needs an answer
- use `Action` when the client is asking the server to do work
- use `Signal` when the server needs to announce something
- use `Shared` for local public methods that should be easy to discover

For example, `GetItems` is a Query because the caller expects a list back.
`EquipItem` is an Action because the caller is requesting work. `ItemAdded` is a
Signal because the server chooses when to send it.

## Surface Names Are Public Names

Keep surface names stable and clear. They are the names client code will call.
Renaming a surface is like renaming a public function.

Previous: [Clean](clean.md)  
Next: [Networking](networking.md)
