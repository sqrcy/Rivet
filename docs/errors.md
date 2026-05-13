# Errors

Rivet errors are intended to identify the failing operation and the Unit or
surface involved.

v1.0 does **not** include generated types or a state system.

Examples:

```text
Rivet missing dependency. Unit "Inventory" depends on missing unit "Data".
```

```text
Rivet circular dependency. Circular Rivet dependency detected: A -> B -> C -> A
```

```text
Rivet contract failed: Inventory.EquipItem arg #1 expected string, got number (server)
```

When a networking contract fails, the call fails before the Unit method runs.
