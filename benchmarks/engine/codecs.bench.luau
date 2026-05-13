--!strict

--[=[
	@class CodecEngineBenchmark

	Standalone scaffold for measuring direct codec encode/decode overhead.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Codec = require(ReplicatedStorage.Rivet.Codec)
local Payloads = require(ReplicatedStorage.Benchmarks.Fixtures.Payloads)

-- Private helpers

local function encodeItem(value: unknown): unknown
	local item = value :: {
		Id: string,
		Count: number,
		Tags: { string },
	}

	return {
		Id = item.Id,
		Count = item.Count,
		Tags = table.clone(item.Tags),
	}
end

local function decodeItem(data: unknown): unknown
	local encoded = data :: {
		Id: string,
		Count: number,
		Tags: { string },
	}

	return {
		Id = encoded.Id,
		Count = encoded.Count,
		Tags = table.clone(encoded.Tags),
	}
end

-- Public API

local codecId = "EngineBenchmarkItem"
local iterations = 10_000

pcall(function()
	Codec:Register(codecId, {
		Encode = encodeItem,
		Decode = decodeItem,
	})
end)

local startedAt = os.clock()

for index = 1, iterations do
	local encoded =
		Codec.EncodeReturn("BenchmarkUnit", "DirectCodec", codecId, Payloads.item(index), "engine")

	Codec.DecodeReturn("BenchmarkUnit", "DirectCodec", codecId, encoded, "engine")
end

return {
	Name = "codecs-direct",
	Seconds = os.clock() - startedAt,
	Calls = iterations,
}
