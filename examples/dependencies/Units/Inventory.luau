--!strict

--[=[
	@class DependenciesInventoryExample

	Unit that waits for the Data dependency before Init runs.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Public API

local Inventory = {}

Inventory.Id = "Inventory"
Inventory.Dependencies = { "Data" }

function Inventory.Init(self: UnitContext)
	self.Data = self:Get("Data")
end

return Inventory
