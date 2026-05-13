--!strict

--[=[
	@class PluginsBootExample

	Registers a plugin before starting Rivet.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local LogPlugin = require(script.Parent.LogPlugin)

-- Public API

Rivet.Use(LogPlugin)

Rivet.Start({
	Roots = {
		ReplicatedStorage.ExampleUnits,
	},
})
