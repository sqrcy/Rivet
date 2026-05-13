--!strict

--[=[
	@class LogPluginExample

	Minimal plugin that observes Unit lifecycle hooks.
]=]

-- Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Rivet.Types)

-- Public API

local LogPlugin: Types.Plugin = {
	Id = "LogPlugin",
}

LogPlugin.OnUnitStart = function(_self: Types.Plugin, unit: Types.UnitContext)
	print("Started Unit", unit.Id)
end

return LogPlugin
