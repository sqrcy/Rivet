# Contracts

Contracts are optional runtime checks for network surfaces.

They help catch simple mistakes at the edge of your game, where client and
server code talk to each other.

Luau types are checked while you write code. Contracts are checked while the
game runs. That makes them useful for values crossing remotes, because those
calls happen at runtime.

## Args

Use `Args` to check values sent into a Query or Action.

```lua
Inventory.Surfaces = {
	Client = {
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
	},
}
```

Now `Inventory:EquipItem(123)` fails because the first argument should be a
string.

Args are listed in the same order as the values the client passes. Do not count
the server-side `player` argument; Rivet adds that for the server method.

## Returns

Use `Returns` to check the result of a Query.

```lua
GetItems = {
	Kind = "Query",
	Returns = "table",
}
```

Returns are checked after the server method runs and before the result is sent
back to the client.

## Payload

Use `Payload` to check Signal values.

```lua
ItemAdded = {
	Kind = "Signal",
	Payload = { "string", "number" },
}
```

Payload entries are checked before a Signal is fired.

## Built-In Names

Common contract names include:

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

Custom names are handled with codecs.

## Start Small

You do not need to contract everything at once. A good first pass is to add
contracts to surfaces that accept player input or return structured data.

```lua
BuyItem = {
	Kind = "Action",
	Args = { "string", "number" },
}
```

This makes the error immediate when the caller sends the wrong shape.

Previous: [Networking](networking.md)  
Next: [Codecs](codecs.md)
