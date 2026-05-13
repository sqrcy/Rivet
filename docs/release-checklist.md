# Release Checklist

Use this checklist before publishing Rivet.

- All TestEZ specs pass through Open Cloud Luau Execution.
- `luau-lsp analyze` passes for `src`, `tests`, and `examples`.
- `selene src tests examples` passes.
- `stylua --check src tests examples` passes.
- `wally package --list` shows only intended package files.
- `wally.toml` has the intended version, author, license, and package name.
- `CHANGELOG.md` documents the release.
- Docs and examples match the stable API.
- `release.project.json` builds the package-only model when a `.rbxm` artifact is
  needed.

Do not publish to Wally or Roblox automatically from this repository without an
explicit release command.
