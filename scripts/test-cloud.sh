#!/usr/bin/env bash
set -euo pipefail

required_vars=(
	"ROBLOX_API_KEY"
	"RIVET_TEST_UNIVERSE_ID"
	"RIVET_TEST_PLACE_ID"
)

missing_vars=()

for var_name in "${required_vars[@]}"; do
	if [[ -z "${!var_name:-}" ]]; then
		missing_vars+=("${var_name}")
	fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
	printf 'Missing required environment variable(s): %s\n' "${missing_vars[*]}" >&2
	printf 'See .env.example for setup.\n' >&2
	exit 2
fi

timeout="${RIVET_CLOUD_TEST_TIMEOUT:-300}"
poll_interval="${RIVET_CLOUD_TEST_POLL_INTERVAL:-2}"
upload_retries="${RIVET_CLOUD_TEST_UPLOAD_RETRIES:-3}"
retry_delay="${RIVET_CLOUD_TEST_RETRY_DELAY:-120}"

if command -v aftman >/dev/null 2>&1; then
	aftman_bin="$(dirname "$(command -v aftman)")"
	export PATH="${aftman_bin}:${PATH}"
fi

mkdir -p tmp

wally install

attempt=1
output_file="tmp/rocale-test-output.log"

while true; do
	printf 'Starting cloud test attempt %s/%s...\n' "${attempt}" "${upload_retries}"

	set +e
	rocale-cli run \
		--load.project test.project.json \
		--output tmp/rivet-tests.rbxlx \
		--script tests/RunTests.luau \
		--universeId "${RIVET_TEST_UNIVERSE_ID}" \
		--placeId "${RIVET_TEST_PLACE_ID}" \
		--timeout "${timeout}" \
		--pollInterval "${poll_interval}" 2>&1 | tee "${output_file}"
	status="${PIPESTATUS[0]}"
	set -e

	if [[ "${status}" -eq 0 ]]; then
		exit 0
	fi

	if [[ "${attempt}" -ge "${upload_retries}" ]]; then
		exit "${status}"
	fi

	if ! grep -q '409 - {"code":"Conflict"' "${output_file}"; then
		exit "${status}"
	fi

	attempt=$((attempt + 1))
	printf 'Roblox returned a transient upload conflict. Retrying in %s seconds...\n' "${retry_delay}" >&2
	sleep "${retry_delay}"
done
