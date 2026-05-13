--!strict

--[=[
	@class CircularCFixture

	Test unit in a dependency cycle.
]=]

-- Public API

local C = {}

C.Id = "C"
C.Dependencies = { "A" }

return C
