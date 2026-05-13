--!strict

--[=[
	@class BadDependenciesFixture

	Test unit with invalid dependency entries.
]=]

-- Public API

local BadDependencies = {}

BadDependencies.Id = "BadDependencies"
BadDependencies.Dependencies = { 1 }

return BadDependencies
