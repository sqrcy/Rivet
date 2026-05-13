# Lifecycle

Rivet gives every managed Unit a simple lifecycle:

1. prepare
2. `Init`
3. `Start`
4. `Destroy`

## Prepare

Prepare is Rivet's internal setup step. This is when Rivet attaches fields like
`self.Clean` and `self:Get`.

You do not write a prepare method.

## Init

Use `Init` to connect dependencies and set up internal state.

```lua
function Inventory:Init()
	self.Data = self:Get("Data")
	self.Items = {}
end
```

`Init` is the best place to read other Units because dependencies are already
prepared.

## Start

Use `Start` when the Unit is ready to do work.

```lua
function Inventory:Start()
	print("Inventory started")
end
```

Rivet waits until every Unit has finished `Init` before it calls any `Start`
method.

## Destroy

Use `Destroy` for custom shutdown behavior.

```lua
function Inventory:Destroy()
	print("Inventory stopping")
end
```

After `Destroy`, Rivet also cleans `self.Clean`.

Previous: [Dependencies](dependencies.md)  
Next: [Clean](clean.md)
