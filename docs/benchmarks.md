# Benchmarks

Rivet v1.0 includes benchmark scaffolds under `benchmarks/`.

v1.0 does **not** include generated types or a state system.

Current benchmark scripts:

- `benchmarks/boot.bench.luau`
- `benchmarks/cleanup.bench.luau`
- `benchmarks/networking.bench.luau`

Benchmarks should run in a Roblox place so they have the same DataModel and
engine APIs as normal Rivet code. Treat the results as environment-specific
measurements, not universal performance claims.

Report:

- machine or cloud environment
- Roblox execution mode
- number of Units or calls
- total elapsed seconds
- per-call or per-Unit average when useful
