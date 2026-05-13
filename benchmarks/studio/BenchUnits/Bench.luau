--!strict

--[=[
	@class StudioBenchmarkBenchUnit

	Live client/server benchmark Unit for Rivet remote measurements.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)

-- Private helpers

local function clientSignal(self: unknown, name: string): Internal.DynamicTable
	local unit = self :: Internal.DynamicTable
	local client = unit.Client :: Internal.DynamicTable

	return client[name] :: Internal.DynamicTable
end

-- Public API

local Bench = {}

Bench.Id = "Bench"
Bench.Surfaces = {
	Client = {
		Ping = "Query",
		ActionPing = "Action",
		Fanout = "Action",
		ActionEcho = "Signal",
		FanoutEcho = "Signal",
	},
}

function Bench.Ping(_self: unknown, _player: Player, sentAt: number, payload: string)
	return {
		SentAt = sentAt,
		ServerAt = os.clock(),
		PayloadBytes = #payload,
	}
end

function Bench.ActionPing(
	self: unknown,
	player: Player,
	sequence: number,
	sentAt: number,
	payload: string
)
	clientSignal(self, "ActionEcho"):Fire(player, sequence, sentAt, os.clock(), #payload)
end

function Bench.Fanout(
	self: unknown,
	_player: Player,
	sequence: number,
	sentAt: number,
	payload: string
)
	clientSignal(self, "FanoutEcho"):FireAll(sequence, sentAt, os.clock(), #payload)
end

return Bench
