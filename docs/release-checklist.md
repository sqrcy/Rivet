# Release Checklist

Use this checklist before publishing Rivet.

- Confirm `wally.toml` has the intended package name, version, author, and
  license.
- Run all local checks from [Testing](testing.md).
- Run the Open Cloud TestEZ suite.
- Update the benchmark report if performance-sensitive code changed.
- Run `wally package --list` and verify the plain package contents.
- Review `README.md`, `CHANGELOG.md`, and the docs.
- Build the package-only model if a `.rbxm` artifact is needed:

```sh
rojo build release.project.json --output tmp/Rivet.rbxm
```

Publishing is a manual final step.

Previous: [Benchmarks](benchmarks.md)  
Next: [Versioning](versioning.md)
