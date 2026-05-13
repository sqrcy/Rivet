# Versioning

Rivet v1.0 is the first stable API milestone for this package.

v1.0 does **not** include generated types or a state system.

Stable public API:

- `Rivet.Start(config)`
- `Rivet.Get(id)` and `Rivet:Get(id)`
- `Rivet.Destroy()`
- `Rivet.Use(plugin)`
- `Rivet.Codec:Register(id, codec)`
- `Rivet.Clean.new()`
- `Rivet.Debug:GetNetworkStats()`

Stable Unit metadata:

- `Unit.Id`
- `Unit.Dependencies`
- `Unit.Surfaces`

Stable Unit lifecycle:

- `Unit:Init()`
- `Unit:Start()`
- `Unit:Destroy()`

Stable runtime fields:

- `self.Clean`
- `self:Get(id)`
- `self.Client` for server-side signal helpers
