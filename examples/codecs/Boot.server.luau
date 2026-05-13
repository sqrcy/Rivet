--!strict

--[=[
	@class CodecsBootExample

	Registers a codec before starting Rivet.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Item = require(script.Parent.Item)

-- Public API

Rivet.Codec:Register("Item", {
	Encode = function(value: unknown): unknown
		local item = value :: {
			Id: string,
			Count: number,
		}

		return {
			Id = item.Id,
			Count = item.Count,
		}
	end,

	Decode = function(data: unknown): unknown
		local encoded = data :: {
			Id: string,
			Count: number,
		}

		return Item.new(encoded.Id, encoded.Count)
	end,
})

Rivet.Start({
	Roots = {
		ReplicatedStorage.ExampleUnits,
	},
})
