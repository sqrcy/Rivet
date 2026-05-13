--!strict

--[=[
	@class PluginsDataExample

	Simple Unit for the plugin example.
]=]

-- Public API

local Data = {}

Data.Id = "Data"

function Data.Start()
	print("Data ready")
end

return Data
