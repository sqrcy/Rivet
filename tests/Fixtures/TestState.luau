--!strict

--[=[
	@class TestState

	Shared deterministic state for Rivet unit fixtures.
]=]

-- Types

type TestState = {
	Events: { string },
	PassiveRequired: boolean,
	LastPlayer: unknown?,
	LastArgs: { unknown },
	LastResult: unknown?,
	SignalEvents: { string },
	Reset: () -> (),
	Push: (eventName: string) -> (),
	Snapshot: () -> { string },
}

-- Public API

local TestState = {} :: TestState

TestState.Events = {}
TestState.PassiveRequired = false
TestState.LastPlayer = nil
TestState.LastArgs = {}
TestState.LastResult = nil
TestState.SignalEvents = {}

function TestState.Reset()
	table.clear(TestState.Events)
	TestState.PassiveRequired = false
	TestState.LastPlayer = nil
	table.clear(TestState.LastArgs)
	TestState.LastResult = nil
	table.clear(TestState.SignalEvents)
end

function TestState.Push(eventName: string)
	table.insert(TestState.Events, eventName)
end

function TestState.Snapshot(): { string }
	return table.clone(TestState.Events)
end

return TestState
