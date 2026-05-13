# Contracts

Runtime contracts are optional metadata for v1.0 Client surfaces. v1.0 does
**not** include codecs, plugins, generated types, or state systems.

```lua
Inventory.Surfaces = {
	Client = {
		GetItems = {
			Kind = "Query",
			Args = { "string" },
			Returns = "table",
		},
		EquipItem = {
			Kind = "Action",
			Args = { "string" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "string", "number" },
		},
	},
}
```

Supported contract names are `nil`, `boolean`, `number`, `string`, `table`,
`Instance`, `Player`, `Vector3`, `CFrame`, `Color3`, `EnumItem`, `buffer`, and
`any`.

If a contract is omitted, Rivet does not validate that part of the call.
Contract errors include the Unit id, surface name, expected type, actual type,
and runtime side.
