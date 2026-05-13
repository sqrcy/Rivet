# Packaging

This page explains exactly what goes into the plain Wally package and how to
publish it.

## Plain Package Contents

The plain package is the runtime package only. It should contain:

- `wally.toml`
- `LICENSE`
- `README.md`
- `CHANGELOG.md`
- `default.project.json`
- `src/Rivet/**`

It should not contain repo-only material such as tests, docs, examples,
benchmarks, local scripts, generated package folders, sourcemaps, or temporary
build output.

The current `wally.toml` exclude list is set up so `wally package --list`
includes only the plain package files.

## Why The Package Is Small

Wally consumers only need the runtime package. Tests, benchmarks, examples, and
docs are useful in this repository, but they should stay out of someone else's
game dependency tree.

Keeping the package small also makes it easier to inspect before publishing.

## Check the Package

Run:

```sh
wally package --list
```

Expected output should be limited to the plain package contents above.

To create a local tarball for inspection:

```sh
wally package --output tmp/rivet-1.0.0.tar.gz
```

You can unpack that tarball locally if you want to verify the exact file tree
before publishing.

## Log In to Wally

Wally uses a GitHub token for registry authentication.

Interactive login:

```sh
wally login
```

Token login:

```sh
wally login --token YOUR_GITHUB_TOKEN
```

If you need to target the configured registry explicitly:

```sh
wally login --api https://github.com/UpliftGames/wally-index --token YOUR_GITHUB_TOKEN
```

## Publish

Before publishing, confirm:

- `wally.toml` has the final version.
- the package name is `sqrcy/rivet`.
- the license is `BSD-3-Clause`.
- `wally package --list` contains only the plain package files.
- tests and static checks have passed.

Then run:

```sh
wally publish
```

Wally publishes the current project using the package metadata in `wally.toml`.
Do not reuse a version number that has already been published.

## Package-Only Roblox Model

To build a plain `.rbxm` artifact for manual release:

```sh
rojo build release.project.json --output tmp/Rivet.rbxm
```

That model is built from the runtime package project, not from the test or
benchmark projects.

Previous: [API Reference](api-reference.md)  
Next: [Testing](testing.md)
