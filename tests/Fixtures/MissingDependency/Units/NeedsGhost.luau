--!strict

--[=[
	@class NeedsGhostFixture

	Test unit with a missing dependency.
]=]

-- Public API

local NeedsGhost = {}

NeedsGhost.Id = "NeedsGhost"
NeedsGhost.Dependencies = { "Ghost" }

return NeedsGhost
