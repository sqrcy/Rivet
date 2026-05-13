# Versioning

Rivet uses normal semantic versioning.

## Patch

Use a patch version for fixes that keep the same public API.

Example:

```text
1.0.1
```

## Minor

Use a minor version for new features that keep existing projects working.

Example:

```text
1.1.0
```

## Major

Use a major version when a public API change requires users to update their
code.

Example:

```text
2.0.0
```

Before publishing any version, update `wally.toml` and `CHANGELOG.md`.

## Release Notes

Use `CHANGELOG.md` to describe what changed in user terms. A useful entry says
what a user can do now, what behavior changed, and whether any setup step is
needed.

Keep benchmark result updates separate from behavior changes when possible so
performance comparisons are easy to review.

Previous: [Release Checklist](release-checklist.md)  
Next: [Docs Index](index.md)
