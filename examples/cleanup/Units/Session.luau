--!strict

--[=[
	@class CleanupSessionExample

	Example Unit using Rivet's built-in cleaner.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

type UnitContext = Types.UnitContext

-- Public API

local Session = {}

Session.Id = "Session"

function Session.Init(self: UnitContext)
	self.Clean:Add(function()
		print("Session cleaned")
	end)
end

return Session
