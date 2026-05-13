# Benchmarks

Benchmarks help answer a different question than tests.

Tests prove that Rivet behaves correctly. Benchmarks show how much work Rivet
does while it behaves correctly. They are useful when you want to compare a
change, check a release, or understand the cost of contracts, codecs, and
network dispatch.

## What Gets Measured

The cloud benchmark runner measures the paths that tend to matter most in a
real game:

- Query dispatch with and without contracts
- Action dispatch with contracts
- Signal firing with payload validation
- codec encode and decode for small objects
- codec encode and decode for larger nested shapes
- Unit boot and cleanup helper overhead
- network debug counters while the calls are running

The complex-shape scenarios use nested tables, arrays, dictionaries, repeated
custom objects, and signal payloads. This makes the benchmark more useful than a
single tiny string call.

## Run The Benchmarks

Set the environment variables from `.env.example`, then run:

```sh
scripts/benchmark-cloud.sh
```

The script:

1. installs Wally development packages
2. builds `benchmark.project.json`
3. uploads the latest benchmark place through `rocale-cli`
4. runs `benchmarks/RunBenchmarks.luau`
5. captures the benchmark JSON from the Roblox log
6. writes `tmp/rivet-benchmark-results.json`
7. updates `docs/benchmark-results.md`

The generated Markdown report is the file to commit when you want benchmark
numbers in the docs.

## Configure A Run

The default benchmark is meant to be useful without being slow. You can make it
more precise by increasing samples and iterations.

```sh
RIVET_BENCHMARK_SAMPLES=12 scripts/benchmark-cloud.sh
```

Available controls:

- `RIVET_BENCHMARK_SAMPLES`: how many timing samples to record per scenario
- `RIVET_BENCHMARK_WARMUPS`: how many calls to run before measuring
- `RIVET_BENCHMARK_ITERATIONS`: calls per sample for simple scenarios
- `RIVET_BENCHMARK_BOOT_ITERATIONS`: start/destroy passes per sample
- `RIVET_BENCHMARK_CLEANUP_ITERATIONS`: cleaner passes per sample
- `RIVET_BENCHMARK_CLEANUP_TASKS`: cleanup tasks added per cleaner pass
- `RIVET_BENCHMARK_CODEC_ITERATIONS`: calls per sample for small codec scenarios
- `RIVET_BENCHMARK_COMPLEX_ITERATIONS`: calls per sample for large payloads
- `RIVET_BENCHMARK_COMPLEX_SIZE`: how many item-like entries go into each large payload

More samples make the averages steadier. More iterations make each sample less
noisy. Larger complex payloads make codec cost easier to see.

## Read The Report

The report uses microseconds per operation. Lower mean and median values are
better.

The most useful columns are:

- `Mean us/op`: average time per operation across all samples
- `Median us/op`: middle sample, useful when one sample was unusually slow
- `Std dev us`: how much samples moved around
- `Ops/sec`: rough throughput from the mean
- `Samples`: how many timing passes were averaged
- `Iterations`: how many operations were inside each timing pass

Always compare benchmark runs made with the same settings. If you change sample
count, iteration count, or complex payload size, note that in the report or PR.

## Expected Output Files

After a successful run:

- `docs/benchmark-results.md` contains the formatted report
- `tmp/rivet-benchmark-results.json` contains the raw benchmark data
- `tmp/rocale-benchmark-output.log` contains the full cloud runner log
- `tmp/rivet-benchmarks.rbxlx` contains the built benchmark place

Only the Markdown report is intended for documentation. Files under `tmp/` are
local run output.

Previous: [Cloud Testing](cloud-testing.md)  
Next: [Benchmark Results](benchmark-results.md)
