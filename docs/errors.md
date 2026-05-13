# Errors

Rivet tries to make startup and runtime errors point to the thing you can fix.

When something fails, read the message from left to right:

1. what Rivet was doing
2. which Unit or surface was involved
3. what value was expected
4. what to change

## Missing Dependency

```text
Rivet missing dependency. Unit "Inventory" depends on missing unit "Data".
```

This means Rivet loaded `Inventory`, saw `Dependencies = { "Data" }`, and could
not find a Unit with `Id = "Data"` in the configured roots.

## Circular Dependency

```text
Rivet circular dependency. Circular Rivet dependency detected: A -> B -> C -> A
```

This means the dependency chain loops back to where it started.

## Contract Failure

```text
Rivet contract failed: Inventory.EquipItem arg #1 expected string, got number
```

This means a surface call reached a contract and the value did not match.

## Duplicate Unit Id

```text
Rivet duplicate unit id "Inventory".
```

Two loaded Units are trying to use the same id. Rename one of the Units or give
it a more specific `Id`.

## Surface Error

```text
Rivet invalid surface. Unit "Inventory" exposes Client.GetItems as Query, but method Inventory:GetItems does not exist.
```

The surface table declared a method name, but the Unit table did not define that
method. Add the method or remove the surface entry.

## Debugging Order

When an error mentions a Unit id, open that Unit first. Then check:

1. its `Id`
2. its `Dependencies`
3. its `Surfaces`
4. any contracts or codecs used by that surface

Most Rivet errors come from one of those declarations being out of sync with the
methods on the table.

Previous: [Plugins](plugins.md)  
Next: [API Reference](api-reference.md)
