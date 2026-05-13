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

Previous: [API Reference](api-reference.md)  
Next: [Testing](testing.md)
