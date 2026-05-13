--!strict

--[=[
	@class CircularAFixture

	Test unit in a dependency cycle.
]=]

-- Public API

local A = {}

A.Id = "A"
A.Dependencies = { "B" }

return A
