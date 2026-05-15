# Rivet

Rivet is a Roblox/Luau systems layer for games that have outgrown loose startup scripts and scattered remotes. It gives top-level game systems a managed lifecycle, predictable dependency order, explicit networking surfaces, cleanup, validation, and extension hooks while keeping the code itself plain Luau.

Use Rivet for the systems that should feel like real runtime services: inventory, data, economy, rounds, matchmaking, quests, notifications, combat state, and other modules that need to start, talk to each other, expose safe client APIs, and shut down cleanly.

## Why Use Rivet

### Managed Systems Without Ceremony

Units are ordinary ModuleScripts that return tables. Rivet adds the part Roblox projects usually end up rebuilding by hand: startup order, `Init`/`Start`/`Destroy`, dependency lookup, and reverse-order teardown.

### Explicit Client APIs

Client access is declared through surfaces. A Unit can expose a request/response `Query`, a one-way `Action`, or a server-pushed `Signal` without making every server method reachable from the client.

### Safer Runtime Boundaries

Contracts validate values at remote boundaries, and codecs give custom domain objects an explicit encode/decode path. Bad traffic fails close to the surface that received it, which makes networking bugs easier to understand.

### Cleanup Built In

Every Unit gets a cleanup helper for functions, Instances, connections, and objects with cleanup-style methods. Runtime teardown becomes a normal part of the system instead of a pile of one-off disconnect calls.

### Hooks For Tooling And Diagnostics

Plugins can observe lifecycle events, surface registration, network calls, and runtime errors. That makes it straightforward to add logging, metrics, policy checks, or project-specific diagnostics without copying that code into every Unit.

## Documentation

[Documentation](https://sqrcy.github.io/Rivet/)

## License

Rivet is licensed under BSD-3-Clause.
