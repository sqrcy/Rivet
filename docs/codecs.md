# Codecs

Roblox remotes can send simple values easily. Game objects often need a little
help.

A codec teaches Rivet how to turn a custom object into remote-safe data and how
to rebuild it on the other side.

## Register a Codec

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

## Use the Codec in a Contract

```lua
Inventory.Surfaces = {
	Client = {
		GetItem = {
			Kind = "Query",
			Returns = "Item",
		},
		ItemAdded = {
			Kind = "Signal",
			Payload = { "Item" },
		},
	},
}
```

The contract name `Item` matches the codec id.

## Keep Codecs Explicit

Rivet uses the codec id you registered. It does not guess from table shape or
metatables. That keeps network behavior visible in your code.

Previous: [Contracts](contracts.md)  
Next: [Plugins](plugins.md)
