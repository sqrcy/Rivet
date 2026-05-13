# Lifecycle

Rivet v1.0 has three lifecycle moments: prepare, `Init`, and `Start`.

v1.0 does **not** include generated types or a state system.

## Boot

1. Rivet loads Unit ModuleScripts under configured roots.
2. Rivet validates ids, dependencies, and lifecycle methods.
3. Rivet sorts Units so dependencies boot before dependents.
4. Rivet attaches runtime fields, including `self.Clean` and `self:Get`.
5. Rivet runs every `Init`.
6. Rivet runs every `Start`.

All `Init` methods finish before any `Start` method runs.

## Destroy

`Rivet.Destroy()` runs Units in reverse boot order.

For each Unit:

1. Call optional `Destroy`.
2. Run `self.Clean:Cleanup()`.

Calling `Rivet.Destroy()` when Rivet has not started is safe.

Calling `Rivet.Start` twice without destroying the current runtime errors.
