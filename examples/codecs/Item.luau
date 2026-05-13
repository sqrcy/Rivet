--!strict

--[=[
	@class CodecItemExample

	Small object used by the codec example.
]=]

-- Types

export type Item = {
	Id: string,
	Count: number,
}

-- Public API

local Item = {}

function Item.new(id: string, count: number): Item
	return {
		Id = id,
		Count = count,
	}
end

return Item
