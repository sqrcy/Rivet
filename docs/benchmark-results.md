# Benchmark Results

These results use the benchmark categories described in [Benchmarks](benchmarks.md).

## What The Benchmarks Are

Engine/headless benchmarks measure Rivet runtime overhead in a Roblox
DataModel. Studio remote benchmarks measure live client/server remote
behavior in a local Studio play session.

### Engine/Headless Benchmarks

- **Boot: basic surfaced Unit**: Start and destroy a small Unit root with one declared Query surface.
- **Clean: add and cleanup tasks**: Create a cleaner, add function tasks, and clean them in reverse order.
- **Query: no contracts**: RemoteFunction dispatch through a declared Query surface.
- **Query: string contract**: Client arg validation, server dispatch, return validation.
- **Action: string contract**: RemoteEvent dispatch with primitive arg validation.
- **Signal: number payload**: Server signal wrapper with primitive payload validation.
- **Query: item codec return**: Server encodes and client decodes a small custom object.
- **Action: item codec arg**: Client encodes and server decodes a small custom object.
- **Signal: item codec payload**: Server signal encodes and benchmark sink decodes a small object.
- **Query: complex codec return**: Nested tables, arrays, dictionaries, and repeated object entries.
- **Action: complex codec arg**: Client encode and server decode for a larger nested payload.
- **Signal: complex codec payload**: Signal payload encode/decode path for a larger nested payload.

### Studio Remote Benchmarks

- **Native RemoteFunction**: native request/response baseline.
- **Rivet Query**: Rivet Query proxy over RemoteFunction.
- **Native RemoteEvent echo**: native event round trip with server echo.
- **Rivet Action echo**: Rivet Action request echoed through a Rivet Signal.
- **Rivet Signal fanout**: server FireAll signal delivery to the benchmark client.

## Engine/Headless Results

| Scenario | Category | Mean us/op | Median us/op | Min us/op | Max us/op | Std dev us | Ops/sec | Samples | Iterations |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Boot: basic surfaced Unit | Runtime | 51.63 | 48.22 | 40.83 | 65.39 | 10.81 | 19,368 | 7 | 50 |
| Clean: add and cleanup tasks | Runtime | 370.01 | 366.04 | 357.28 | 393.18 | 13.73 | 2,703 | 7 | 100 |
| Query: no contracts | Networking | 8.23 | 7.68 | 7.39 | 10.12 | 1.07 | 121,459 | 7 | 1000 |
| Query: string contract | Contracts | 10.23 | 9.36 | 8.42 | 13.10 | 1.90 | 97,770 | 7 | 1000 |
| Action: string contract | Contracts | 8.17 | 7.66 | 7.49 | 10.35 | 1.04 | 122,448 | 7 | 1000 |
| Signal: number payload | Contracts | 8.47 | 7.95 | 7.82 | 10.29 | 0.91 | 118,004 | 7 | 1000 |
| Query: item codec return | Codecs | 11.59 | 11.22 | 10.48 | 12.81 | 0.89 | 86,316 | 7 | 250 |
| Action: item codec arg | Codecs | 12.52 | 12.33 | 11.46 | 14.66 | 1.05 | 79,868 | 7 | 250 |
| Signal: item codec payload | Codecs | 11.13 | 11.14 | 10.93 | 11.53 | 0.21 | 89,877 | 7 | 250 |
| Query: complex codec return | Complex Shapes | 167.09 | 166.01 | 161.68 | 178.84 | 5.76 | 5,985 | 7 | 100 |
| Action: complex codec arg | Complex Shapes | 165.24 | 164.82 | 163.64 | 168.97 | 1.85 | 6,052 | 7 | 100 |
| Signal: complex codec payload | Complex Shapes | 160.17 | 159.10 | 156.26 | 165.46 | 3.37 | 6,243 | 7 | 100 |

## Network Debug Counters

| Unit | Surface | Kind | Calls | Failures |
| --- | --- | --- | ---: | ---: |
| BenchmarkUnit | AcceptString | Action | 7050 | 0 |
| BenchmarkUnit | BroadcastComplex | Signal | 750 | 0 |
| BenchmarkUnit | BroadcastItem | Signal | 1800 | 0 |
| BenchmarkUnit | BroadcastNumber | Signal | 7050 | 0 |
| BenchmarkUnit | EchoString | Query | 7050 | 0 |
| BenchmarkUnit | GetComplex | Query | 750 | 0 |
| BenchmarkUnit | GetItem | Query | 1800 | 0 |
| BenchmarkUnit | Ping | Query | 7050 | 0 |
| BenchmarkUnit | UseComplex | Action | 750 | 0 |
| BenchmarkUnit | UseItem | Action | 1800 | 0 |

## Reading The Numbers

The benchmark reports microseconds per operation. Lower mean and median values are better. The standard deviation column shows how much samples moved around during the run.

Use the numbers as a comparison point between Rivet changes. The most useful signal is how a scenario moves relative to its previous result.

For live Studio remote results, compare P50, P95, P99, and drops together. Remote behavior can look healthy on average while still showing high-percentile spikes or throttled requests.

## Live Studio Remote Benchmarks

Environment:

- Roblox Studio version: not captured
- OS: not captured
- CPU: not captured
- Client count: 1
- Iterations: 500
- Warmup iterations: 0
- Payload: 0, 128, 1024, and 8192 bytes
- Runner: Rojo-served Studio play session
- Timeout: 5 seconds

| Benchmark | Payload bytes | Mean ms | Median ms | P95 ms | P99 ms | Min ms | Max ms | Drops | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Native RemoteFunction | 0 | 53.57 | 49.99 | 53.65 | 166.42 | 32.89 | 419.49 | 0 | Native request/response baseline. |
| Rivet Query | 0 | 49.86 | 49.93 | 50.72 | 50.99 | 33.39 | 51.17 | 0 | Rivet Query proxy over RemoteFunction. |
| Native RemoteEvent echo | 0 | 58.71 | 49.80 | 97.87 | 107.39 | 32.98 | 116.04 | 0 | Native RemoteEvent client-to-server-to-client echo. |
| Rivet Action echo | 0 | 49.87 | 49.51 | 50.44 | 73.43 | 32.94 | 82.84 | 0 | Rivet Action request echoed through a Rivet Signal. |
| Rivet Signal fanout | 0 | 49.27 | 49.49 | 50.20 | 50.50 | 32.02 | 66.14 | 0 | Rivet server FireAll signal delivery to the benchmark client. |
| Native RemoteFunction | 128 | 49.69 | 49.95 | 50.62 | 50.91 | 33.19 | 66.69 | 0 | Native request/response baseline. |
| Rivet Query | 128 | 49.96 | 49.99 | 50.60 | 50.91 | 33.24 | 51.13 | 0 | Rivet Query proxy over RemoteFunction. |
| Native RemoteEvent echo | 128 | 49.35 | 49.56 | 50.28 | 50.51 | 32.78 | 50.92 | 0 | Native RemoteEvent client-to-server-to-client echo. |
| Rivet Action echo | 128 | 49.38 | 49.64 | 50.37 | 50.77 | 31.74 | 50.97 | 0 | Rivet Action request echoed through a Rivet Signal. |
| Rivet Signal fanout | 128 | 49.55 | 49.62 | 50.32 | 50.66 | 32.97 | 51.00 | 0 | Rivet server FireAll signal delivery to the benchmark client. |
| Native RemoteFunction | 1024 | 49.79 | 49.97 | 50.67 | 50.97 | 32.84 | 51.12 | 0 | Native request/response baseline. |
| Rivet Query | 1024 | 49.73 | 49.97 | 50.93 | 51.42 | 32.77 | 66.94 | 0 | Rivet Query proxy over RemoteFunction. |
| Native RemoteEvent echo | 1024 | 49.21 | 49.48 | 51.00 | 51.40 | 31.03 | 51.60 | 0 | Native RemoteEvent client-to-server-to-client echo. |
| Rivet Action echo | 1024 | 49.27 | 49.50 | 51.13 | 51.54 | 32.04 | 51.70 | 0 | Rivet Action request echoed through a Rivet Signal. |
| Rivet Signal fanout | 1024 | 49.14 | 49.48 | 51.09 | 51.42 | 32.13 | 65.92 | 0 | Rivet server FireAll signal delivery to the benchmark client. |
| Native RemoteFunction | 8192 | 50.06 | 49.98 | 51.57 | 65.75 | 33.09 | 67.14 | 0 | Native request/response baseline. |
| Rivet Query | 8192 | 50.03 | 50.02 | 51.54 | 66.11 | 32.61 | 67.17 | 0 | Rivet Query proxy over RemoteFunction. |
| Native RemoteEvent echo | 8192 | 49.61 | 49.53 | 51.36 | 66.22 | 32.07 | 84.52 | 0 | Native RemoteEvent client-to-server-to-client echo. |
| Rivet Action echo | 8192 | 49.40 | 49.56 | 51.20 | 66.05 | 31.05 | 66.73 | 0 | Rivet Action request echoed through a Rivet Signal. |
| Rivet Signal fanout | 8192 | 49.56 | 49.66 | 51.21 | 51.71 | 32.30 | 66.40 | 0 | Rivet server FireAll signal delivery to the benchmark client. |

Previous: [Benchmarks](benchmarks.md)
