--!strict

--[=[
	@class ItemFixture

	Small object type used by codec tests.
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
