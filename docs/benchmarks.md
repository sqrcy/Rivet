# Benchmarks

Rivet uses two benchmark categories because they answer different questions.

**Engine/headless benchmarks** run through Open Cloud Luau Execution. They are
best for measuring Rivet framework overhead inside a Roblox DataModel without a
live client.

**Studio remote benchmarks** run in a local Roblox Studio play session. They are
best for measuring real client/server remote behavior with Rivet included.

Keeping these separate prevents one set of numbers from pretending to answer
both questions.

## Engine/Headless Benchmarks

### Boot: Basic Surfaced Unit

Starts and destroys a small Unit root with one declared Query surface.

This shows the cost of Rivet's startup path: loading a Unit, normalizing
surface metadata, creating remotes, preparing runtime fields, and tearing the
runtime back down.

### Clean: Add And Cleanup Tasks

Creates a cleaner, adds many function tasks, and cleans them in reverse order.

This shows the cost of Rivet's built-in cleanup utility when a Unit tracks many
small cleanup tasks.

### Query: No Contracts

Dispatches a declared Query surface without contract or codec work.

This is the baseline for Rivet's internal request/response dispatch path before
extra validation is added.

### Query: String Contract

Dispatches a Query with a string argument contract and a string return contract.

This shows the overhead of validating client arguments, dispatching the server
method, validating the return value, and sending the result back.

### Action: String Contract

Dispatches an Action with a string argument contract.

This shows the one-way internal dispatch path for client-to-server work that
does not return a value.

### Signal: Number Payload

Fires a server Signal with a number payload contract.

This shows the server signal wrapper path, including payload validation and
dispatch through the signal helper.

### Query: Item Codec Return

Returns a small custom object from a Query.

This shows the cost of encoding a server object into remote-safe data and
decoding it back into an object-like value for the caller.

### Action: Item Codec Arg

Sends a small custom object into an Action.

This shows the argument codec path: encode the value, dispatch the Action, then
decode it for the server method.

### Signal: Item Codec Payload

Fires a Signal with a small custom object payload.

This shows codec cost on a server-pushed event payload.

### Query: Complex Codec Return

Returns a larger nested payload from a Query.

The payload contains arrays, dictionaries, repeated custom objects, booleans,
numbers, and trace entries. This shows how codec cost grows when the shape is
closer to real game data.

### Action: Complex Codec Arg

Sends the same larger nested payload into an Action.

This shows the cost of moving a structured custom value across a surfaced
Action.

### Signal: Complex Codec Payload

Fires a Signal with the larger nested payload.

This shows the cost of pushing structured data through a Signal.

## Studio Remote Benchmarks

### Native RemoteFunction

The client calls a native `RemoteFunction`; the server returns the original
timestamp and a server timestamp.

This is the native request/response baseline for live Studio networking.

### Rivet Query

The client calls a Rivet Query surface that returns the same timestamp shape.

This shows how Rivet Query latency compares with the native RemoteFunction
baseline.

### Native RemoteEvent Echo

The client fires a native `RemoteEvent`; the server echoes the payload back to
that client.

This measures event round-trip behavior and records drops/timeouts.

Remote events can be throttled when a client sends too much too quickly, so this
benchmark looks at high percentiles and drops instead of only average latency.

### Rivet Action Echo

The client fires a Rivet Action; the server echoes through a Rivet Signal.

This shows the live one-way Action request path plus the signal response needed
to measure round-trip latency.

### Rivet Signal Fanout

The client requests a server `FireAll` signal fanout and records when it receives
the signal.

This shows server-to-client fanout behavior with Rivet's Signal wrapper.

### Payload Size Effects

The Studio remote benchmarks run each remote shape with multiple payload sizes.

This shows how latency changes as the payload moves from empty strings to larger
strings, and helps reveal throttling, drops, or high-percentile spikes.

Next: [Benchmark Results](benchmark-results.md)
