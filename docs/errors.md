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

Previous: [Plugins](plugins.md)  
Next: [API Reference](api-reference.md)
