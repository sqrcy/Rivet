--!strict

--[=[
	@class BasicBootExample

	Minimal Rivet boot script.
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

local Inventory = Rivet:Get("Inventory")
print("Inventory unit started:", Inventory.Id)

Rivet.Destroy()
