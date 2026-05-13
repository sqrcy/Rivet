--!strict

--[=[
	@class Data

	Example data Unit.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Public API

local Data = {}

Data.Id = "Data"
Data.Profiles = {}

function Data.Init(self: UnitContext)
	self.Clean:Add(function()
		table.clear(Data.Profiles)
	end)
end

function Data.Start(_self: UnitContext)
	print("Data started")
end

return Data
