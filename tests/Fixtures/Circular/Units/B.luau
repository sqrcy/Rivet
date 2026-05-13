--!strict

--[=[
	@class CircularBFixture

	Test unit in a dependency cycle.
]=]

-- Public API

local B = {}

B.Id = "B"
B.Dependencies = { "C" }

return B
