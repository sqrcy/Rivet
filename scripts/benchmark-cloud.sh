#!/usr/bin/env bash
set -euo pipefail

required_vars=(
	"ROBLOX_API_KEY"
)

missing_vars=()

for var_name in "${required_vars[@]}"; do
	if [[ -z "${!var_name:-}" ]]; then
		missing_vars+=("${var_name}")
	fi
done

universe_id="${RIVET_BENCHMARK_UNIVERSE_ID:-${RIVET_TEST_UNIVERSE_ID:-}}"
place_id="${RIVET_BENCHMARK_PLACE_ID:-${RIVET_TEST_PLACE_ID:-}}"

if [[ -z "${universe_id}" ]]; then
	missing_vars+=("RIVET_BENCHMARK_UNIVERSE_ID or RIVET_TEST_UNIVERSE_ID")
fi

if [[ -z "${place_id}" ]]; then
	missing_vars+=("RIVET_BENCHMARK_PLACE_ID or RIVET_TEST_PLACE_ID")
fi

if [[ ${#missing_vars[@]} -gt 0 ]]; then
	printf 'Missing required environment variable(s): %s\n' "${missing_vars[*]}" >&2
	printf 'See .env.example and docs/benchmarks.md for setup.\n' >&2
	exit 2
fi

timeout="${RIVET_BENCHMARK_TIMEOUT:-300}"
poll_interval="${RIVET_BENCHMARK_POLL_INTERVAL:-2}"
upload_retries="${RIVET_BENCHMARK_UPLOAD_RETRIES:-3}"
retry_delay="${RIVET_BENCHMARK_RETRY_DELAY:-120}"
samples="${RIVET_BENCHMARK_SAMPLES:-7}"
warmups="${RIVET_BENCHMARK_WARMUPS:-50}"
iterations="${RIVET_BENCHMARK_ITERATIONS:-1000}"
boot_iterations="${RIVET_BENCHMARK_BOOT_ITERATIONS:-50}"
cleanup_iterations="${RIVET_BENCHMARK_CLEANUP_ITERATIONS:-100}"
cleanup_tasks="${RIVET_BENCHMARK_CLEANUP_TASKS:-1000}"
codec_iterations="${RIVET_BENCHMARK_CODEC_ITERATIONS:-250}"
complex_iterations="${RIVET_BENCHMARK_COMPLEX_ITERATIONS:-100}"
complex_size="${RIVET_BENCHMARK_COMPLEX_SIZE:-40}"

if command -v aftman >/dev/null 2>&1; then
	aftman_bin="$(dirname "$(command -v aftman)")"
	export PATH="${aftman_bin}:${PATH}"
fi

mkdir -p tmp docs

wally install

attempt=1
output_file="tmp/rocale-benchmark-output.log"
results_file="tmp/rivet-benchmark-results.json"
report_file="docs/benchmark-results.md"

globals="RIVET_BENCHMARK_SAMPLES=${samples},RIVET_BENCHMARK_WARMUPS=${warmups},RIVET_BENCHMARK_ITERATIONS=${iterations},RIVET_BENCHMARK_BOOT_ITERATIONS=${boot_iterations},RIVET_BENCHMARK_CLEANUP_ITERATIONS=${cleanup_iterations},RIVET_BENCHMARK_CLEANUP_TASKS=${cleanup_tasks},RIVET_BENCHMARK_CODEC_ITERATIONS=${codec_iterations},RIVET_BENCHMARK_COMPLEX_ITERATIONS=${complex_iterations},RIVET_BENCHMARK_COMPLEX_SIZE=${complex_size}"

while true; do
	printf 'Starting cloud benchmark attempt %s/%s...\n' "${attempt}" "${upload_retries}"

	set +e
	rocale-cli run \
		--load.project benchmark-engine.project.json \
		--output tmp/rivet-benchmarks.rbxlx \
		--script benchmarks/engine/run.luau \
		--universeId "${universe_id}" \
		--placeId "${place_id}" \
		--timeout "${timeout}" \
		--pollInterval "${poll_interval}" \
		--lua.globals "${globals}" 2>&1 | tee "${output_file}"
	status="${PIPESTATUS[0]}"
	set -e

	if [[ "${status}" -eq 0 ]]; then
		break
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

benchmark_json="$(grep 'RIVET_BENCHMARK_JSON:' "${output_file}" | tail -n 1 | sed 's/^.*RIVET_BENCHMARK_JSON://')"

if [[ -z "${benchmark_json}" ]]; then
	printf 'Benchmark run completed, but no benchmark JSON marker was found.\n' >&2
	exit 1
fi

printf '%s\n' "${benchmark_json}" >"${results_file}"
python3 scripts/render-benchmark-report.py "${results_file}" "${report_file}"
