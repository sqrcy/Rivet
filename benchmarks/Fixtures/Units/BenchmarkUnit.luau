--!strict

--[=[
	@class BenchmarkUnit

	Unit used by Rivet benchmark scenarios.
]=]

-- Constants

local Payloads = require(script.Parent.Parent.Payloads)
local State = require(script.Parent.Parent.State)

-- Types

type BenchmarkItem = {
	Id: string,
	Count: number,
	Tags: { string },
}

type BenchmarkComplex = {
	Id: string,
	Owner: string,
	Version: number,
	Items: { BenchmarkItem },
	Stats: { [string]: number },
	Flags: { [string]: boolean },
	Trace: { { Step: string, Weight: number } },
}

-- Public API

local BenchmarkUnit = {}

BenchmarkUnit.Id = "BenchmarkUnit"
BenchmarkUnit.Surfaces = {
	Client = {
		Ping = "Query",
		EchoString = {
			Kind = "Query",
			Args = { "string" },
			Returns = "string",
		},
		AcceptString = {
			Kind = "Action",
			Args = { "string" },
		},
		BroadcastNumber = {
			Kind = "Signal",
			Payload = { "number" },
		},
		GetItem = {
			Kind = "Query",
			Returns = "BenchmarkItem",
		},
		UseItem = {
			Kind = "Action",
			Args = { "BenchmarkItem" },
		},
		BroadcastItem = {
			Kind = "Signal",
			Payload = { "BenchmarkItem" },
		},
		GetComplex = {
			Kind = "Query",
			Args = { "number" },
			Returns = "BenchmarkComplex",
		},
		UseComplex = {
			Kind = "Action",
			Args = { "BenchmarkComplex" },
		},
		BroadcastComplex = {
			Kind = "Signal",
			Payload = { "BenchmarkComplex" },
		},
	},
}

function BenchmarkUnit.Ping(_self: unknown, player: Player)
	State.LastPlayer = player
	State.Touch(1)

	return 1
end

function BenchmarkUnit.EchoString(_self: unknown, _player: Player, value: string): string
	State.LastValue = value
	State.Touch(#value)

	return value
end

function BenchmarkUnit.AcceptString(_self: unknown, _player: Player, value: string)
	State.LastValue = value
	State.Touch(#value)
end

function BenchmarkUnit.GetItem(_self: unknown, _player: Player)
	local item = Payloads.item(State.Checksum + 1)

	State.LastValue = item
	State.Touch(item.Count)

	return item
end

function BenchmarkUnit.UseItem(_self: unknown, _player: Player, item: BenchmarkItem)
	State.LastValue = item
	State.Touch(item.Count)
end

function BenchmarkUnit.GetComplex(_self: unknown, _player: Player, size: number)
	local payload = Payloads.complex(State.Checksum + 1, size)

	State.LastValue = payload
	State.Touch(#payload.Items)

	return payload
end

function BenchmarkUnit.UseComplex(_self: unknown, _player: Player, payload: BenchmarkComplex)
	State.LastValue = payload
	State.Touch(#payload.Items)
end

return BenchmarkUnit
