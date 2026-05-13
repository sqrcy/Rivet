--!strict

--[=[
	@class BenchmarkState

	Small mutable state store used to keep benchmark calls observable.
]=]

-- Public API

local State = {
	LastValue = nil :: unknown,
	LastPlayer = nil :: Player?,
	Checksum = 0,
}

function State.Reset()
	State.LastValue = nil
	State.LastPlayer = nil
	State.Checksum = 0
end

function State.Touch(amount: number)
	State.Checksum += amount
end

return State
