# Cloud Testing

Rivet uses Roblox Open Cloud Luau Execution for headless Roblox engine tests.

This replaces Studio/plugin-based runners. The cloud test command uploads the
latest test place, creates a Luau Execution task, polls completion, prints task
logs, and exits non-zero when TestEZ fails.

The cloud suite covers the currently implemented milestone behavior. v1.0 does
**not** include codecs, plugins, generated types, or state systems.

## Requirements

Create a dedicated disposable test universe and place. The script overwrites the
configured place each run.

Create an Open Cloud API key scoped to that test universe/place with permission
to:

- Upload place versions.
- Create Luau Execution tasks.
- Read Luau Execution task state and logs.

Depending on the Creator Dashboard permission UI, these may appear as
`universe-places:write`, `universe.place.luau-execution-session:write`, and
`universe.place.luau-execution-session:read`.

## Environment

Set these variables outside the repo or in a local ignored `.env` file:

```sh
export ROBLOX_API_KEY="..."
export RIVET_TEST_UNIVERSE_ID="..."
export RIVET_TEST_PLACE_ID="..."
```

Optional polling controls:

```sh
export RIVET_CLOUD_TEST_TIMEOUT=300
export RIVET_CLOUD_TEST_POLL_INTERVAL=2
export RIVET_CLOUD_TEST_UPLOAD_RETRIES=3
export RIVET_CLOUD_TEST_RETRY_DELAY=120
```

Do not commit API keys or place credentials. Use `.env.example` as the template.

## Run

```sh
scripts/test-cloud.sh
```

The script runs `wally install`, uploads `test.project.json` through
`rocale-cli`, and runs `tests/RunTests.luau` as the Luau Execution entrypoint.
If Roblox returns a transient `409 Conflict` while saving the uploaded place,
the script retries the full cloud run using the configured retry count and
delay.

`tests/RunTests.luau` remains the single TestEZ runner. If any TestEZ spec
fails, it raises an error, causing the cloud task and `rocale-cli` command to
fail.
