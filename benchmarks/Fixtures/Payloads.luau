--!strict

--[=[
	@class BenchmarkPayloads

	Factories for benchmark payloads that stress Rivet codecs with nested shapes.
]=]

-- Types

export type BenchmarkItem = {
	Id: string,
	Count: number,
	Tags: { string },
}

export type BenchmarkComplex = {
	Id: string,
	Owner: string,
	Version: number,
	Items: { BenchmarkItem },
	Stats: { [string]: number },
	Flags: { [string]: boolean },
	Trace: { { Step: string, Weight: number } },
}

-- Public API

local Payloads = {}

function Payloads.item(seed: number): BenchmarkItem
	return {
		Id = `Item-{seed}`,
		Count = seed % 17 + 1,
		Tags = {
			"weapon",
			`tier-{seed % 5}`,
			`seed-{seed}`,
		},
	}
end

function Payloads.complex(seed: number, size: number): BenchmarkComplex
	local items: { BenchmarkItem } = {}
	local trace: { { Step: string, Weight: number } } = {}

	for index = 1, size do
		items[index] = Payloads.item(seed + index)
		trace[index] = {
			Step = `step-{index}`,
			Weight = (seed + index) / math.max(size, 1),
		}
	end

	return {
		Id = `Complex-{seed}`,
		Owner = `Player-{seed % 8}`,
		Version = seed,
		Items = items,
		Stats = {
			Damage = seed * 3,
			Weight = size * 1.5,
			Quality = (seed % 100) / 100,
		},
		Flags = {
			Tradable = seed % 2 == 0,
			Locked = seed % 3 == 0,
			Equipped = seed % 5 == 0,
		},
		Trace = trace,
	}
end

return Payloads
