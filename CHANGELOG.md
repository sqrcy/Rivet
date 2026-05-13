# Changelog

## 1.0.0

- Stabilized the public API: `Rivet.Start`, `Rivet.Get` / `Rivet:Get`,
  `Rivet.Destroy`, `Rivet.Use`, `Rivet.Codec:Register`, `Rivet.Clean`, and
  `Rivet.Debug:GetNetworkStats`.
- Prepared Wally metadata for a BSD-3-Clause v1.0 package by Walker Finch
  (`@sqrcy`).
- Added benchmark scaffolding and final release checklist documentation.
- Confirmed generated types and a state system are intentionally outside v1.0.

## 0.5.0

- Added `Rivet.Use(plugin)` with plugin lifecycle and runtime hooks.
- Added plugin tests for registration, duplicate IDs, lifecycle hooks, failures,
  and destroy hooks.
- Expanded docs and examples for Units, dependencies, cleanup, networking,
  contracts, codecs, and plugins.

## 0.4.0

- Added `Rivet.Codec:Register(id, codec)` for explicit object codecs.
- Added codec encode/decode across Query args/returns, Action args, and Signal
  payloads.
- Added clear missing codec, encode failure, decode failure, and unsupported
  network value errors.

## 0.3.0

- Added optional runtime contracts for Query args/returns, Action args, and
  Signal payloads.
- Added `Rivet.Debug:GetNetworkStats()` for opt-in network call and failure
  counters.
- Improved dependency and contract errors with unit/surface context.

## 0.2.0

- Added Unit `Surfaces` parsing for Client Query/Action/Signal and Shared
  metadata.
- Added basic Query, Action, and Signal networking through generated remotes.
- Added client/server proxy support for declared Client surfaces.
- Preserved v0.1 Units with no Surfaces.

## 0.1.0

- Added the foundational Rivet runtime.
- Added managed Units with ids, dependencies, dependency-sorted boot, lifecycle,
  runtime lookup, and cleanup.
- Added docs, a basic example, and v0.1 test coverage.
- Intentionally omitted networking, remotes, surfaces, codecs, plugins,
  generated types, and state systems.
