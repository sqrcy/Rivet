# Cloud Testing

Rivet uses Roblox Open Cloud Luau Execution for headless Roblox tests.

That means tests run in a real Roblox place without opening Studio.

## What the Script Does

`scripts/test-cloud.sh`:

1. installs Wally packages
2. builds the latest test place from `test.project.json`
3. uploads that place to the configured Roblox test place
4. starts a Luau Execution task
5. runs `tests/RunTests.luau`
6. prints the TestEZ logs
7. exits with an error when tests fail

Use a disposable place for this flow because every run uploads a fresh build.
That keeps the result tied to the current checkout.

## Required Environment

Set these variables outside the repo or in a local ignored `.env` file:

```sh
export ROBLOX_API_KEY="..."
export RIVET_TEST_UNIVERSE_ID="..."
export RIVET_TEST_PLACE_ID="..."
```

The Roblox API key needs access to the dedicated test universe/place for place
upload and Luau Execution task creation/read.

Optional polling controls:

```sh
export RIVET_CLOUD_TEST_TIMEOUT=300
export RIVET_CLOUD_TEST_POLL_INTERVAL=2
export RIVET_CLOUD_TEST_UPLOAD_RETRIES=3
export RIVET_CLOUD_TEST_RETRY_DELAY=120
```

## Run

```sh
scripts/test-cloud.sh
```

## Reading Failures

When TestEZ fails, the command exits with a non-zero status and prints the
failing spec path. Start with the first failing spec and fix that behavior
before rerunning.

When the cloud runner itself fails before TestEZ starts, check the universe id,
place id, API key permissions, and whether another upload is still in progress.

Previous: [Testing](testing.md)  
Next: [Benchmarks](benchmarks.md)
