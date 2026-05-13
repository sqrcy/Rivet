--!strict

--[=[
	@class NetworkingBootExample

	Starts a Unit root with network surfaces.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)

-- Public API

Rivet.Start({
	Roots = {
		ReplicatedStorage.ExampleUnits,
	},
})
