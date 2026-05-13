# Codecs

Rivet v1.0 supports explicit codecs for custom objects crossing network
boundaries. v1.0 does **not** include generated types or a state system.

```lua
Rivet.Codec:Register("Item", {
	Encode = function(item)
		return {
			Id = item.Id,
			Count = item.Count,
		}
	end,

	Decode = function(data)
		return Item.new(data.Id, data.Count)
	end,
})
```

Use the codec id as a contract name:

```lua
Inventory.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "Item",
		},
		UseItem = {
			Kind = "Action",
			Args = { "Item" },
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "Item" },
		},
	},
}
```

Both sides of a network boundary must register matching codec ids. Codec ids are
explicit; Rivet does not guess classes from tables or metatables.
