# Codecs

Roblox remotes can send simple values easily. Game objects often need a little
help.

A codec teaches Rivet how to turn a custom object into remote-safe data and how
to rebuild it on the other side.

Use a codec when a value has meaning beyond a plain table. Item objects,
inventory entries, loadout records, and small domain objects are common fits.

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

## Keep Encoded Data Simple

An encoded value should be made from remote-safe values such as strings, numbers,
booleans, Instances, arrays, and dictionaries.

```lua
Encode = function(item)
	return {
		Id = item.Id,
		Count = item.Count,
	}
end
```

Avoid encoding live connections, functions, or objects that only make sense
inside one script. The goal is to send the information needed to rebuild the
object, not the original object itself.

## Register On Both Sides

Register the same codec id anywhere that needs to encode or decode that object.
Server code may encode the return value of a Query, while client code may decode
the result it receives.

Previous: [Contracts](contracts.md)  
Next: [Plugins](plugins.md)
