--!strict

--[=[
	@class Inventory

	Example Unit that depends on Data.
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

function Inventory.Start(_self: UnitContext)
	print("Inventory started")
end

return Inventory
