# Contracts

Contracts are optional runtime checks for network surfaces.

They help catch simple mistakes at the edge of your game, where client and
server code talk to each other.

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

## Returns

Use `Returns` to check the result of a Query.

```lua
GetItems = {
	Kind = "Query",
	Returns = "table",
}
```

## Payload

Use `Payload` to check Signal values.

```lua
ItemAdded = {
	Kind = "Signal",
	Payload = { "string", "number" },
}
```

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

Previous: [Networking](networking.md)  
Next: [Codecs](codecs.md)
