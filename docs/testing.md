# Testing

Rivet uses local static checks plus Roblox Open Cloud Luau Execution for engine
tests.

v1.0 does **not** include generated types or a state system.

Local checks:

```sh
wally install
rojo sourcemap test.project.json --output sourcemap.json
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json --definitions=dev-types/roblox.d.luau src tests examples
selene src tests examples
stylua --check src tests examples
rojo build test.project.json --output tmp/rivet-tests.rbxlx
wally package --list
```

Engine tests:

```sh
scripts/test-cloud.sh
```

The cloud runner uploads the latest test place, runs `tests/RunTests.luau`, and
fails the command if any TestEZ spec fails.
