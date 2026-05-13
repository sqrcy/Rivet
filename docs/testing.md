# Testing

Rivet has two kinds of checks:

- local checks that catch formatting, lint, type, and build problems
- Roblox engine tests that run the TestEZ suite in a real DataModel

## Local Checks

Run these before publishing:

```sh
wally install
rojo sourcemap test.project.json --output sourcemap.json
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json --definitions=dev-types/roblox.d.luau src tests examples benchmarks
selene src tests examples benchmarks
stylua --check src tests examples benchmarks
rojo build test.project.json --output tmp/rivet-tests.rbxlx
wally package --list
```

## Roblox Engine Tests

Run:

```sh
scripts/test-cloud.sh
```

The cloud runner uploads the latest test place, runs `tests/RunTests.luau`, and
fails the command if any TestEZ spec fails.

Previous: [Packaging](packaging.md)  
Next: [Cloud Testing](cloud-testing.md)
