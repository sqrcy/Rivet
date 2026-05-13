--!strict

--[=[
	@class Rivet

	Rivet framework entrypoint.

	v1.0 includes managed units, surfaces, basic networking, runtime contracts,
	codecs, plugins, network debug stats, runtime lookup, and cleanup.
]=]

-- Types

local Types = require(script.Types)

-- Constants

local Clean = require(script.Clean)
local Codec = require(script.Codec)
local Graph = require(script.Graph)
local Loader = require(script.Loader)
local Network = require(script.Network)
local Plugins = require(script.Plugins)
local Registry = require(script.Registry)
local Runtime = require(script.Runtime)

-- State

local activeRuntime: Types.Runtime? = nil
local activeOrder: { string }? = nil

-- Public API

local Debug = {}

--[=[
	@return NetworkStats

	Returns a snapshot of network debug counters.
]=]
function Debug:GetNetworkStats(): Types.NetworkStats
	return Network.GetNetworkStats()
end

local Rivet = {
	Clean = Clean,
	Codec = Codec,
	Debug = Debug,
} :: Types.Rivet

--[=[
	@param plugin Plugin
	@return Rivet

	Registers an optional plugin before Rivet starts.
]=]
function Rivet.Use(plugin: Types.Plugin): Types.Rivet
	Plugins.Register(plugin)

	return Rivet
end

--[=[
	@param config StartConfig
	@return Rivet

	Starts Rivet and boots all units under `config.Roots`.
]=]
function Rivet.Start(config: Types.StartConfig): Types.Rivet
	if activeRuntime ~= nil then
		error("Rivet has already started; call Rivet.Destroy() before starting again", 2)
	end

	Plugins.Lock()

	local runtime: Types.Runtime? = nil
	local order: { string }? = nil

	local success, result = pcall(function()
		local startConfig = Loader.ValidateConfig(config)
		local registry = Registry.new()
		local records = Loader.Load(startConfig)

		for _, record in ipairs(records) do
			registry:Add(record)
			Plugins.Fire("OnUnitLoaded", record.Unit)
		end

		local preparedRuntime = Runtime.new(registry)
		runtime = preparedRuntime

		for _, id in ipairs(registry:Order()) do
			local record = registry:Get(id)

			preparedRuntime:Prepare(record)
			Plugins.Fire("OnUnitPrepared", record.Unit)
		end

		local sortedOrder = Graph.Sort(registry)
		order = sortedOrder

		Network.Setup(preparedRuntime, registry, startConfig)

		for _, id in ipairs(registry:Order()) do
			local record = registry:Get(id)

			for _, surface in pairs(record.Surfaces.Client) do
				Plugins.Fire("OnSurfaceRegistered", record.Unit, surface)
			end
		end

		Plugins.Init(Rivet)
		preparedRuntime:Init(sortedOrder, function(record: Types.UnitRecord)
			Plugins.Fire("OnUnitInit", record.Unit)
		end)
		preparedRuntime:Start(sortedOrder, function(record: Types.UnitRecord)
			Plugins.Fire("OnUnitStart", record.Unit)
		end)
		Plugins.Start(Rivet)
	end)

	if not success then
		if runtime ~= nil and order ~= nil then
			pcall(function()
				(runtime :: Types.Runtime):Destroy(order :: { string })
			end)
		end

		Plugins.Unlock()
		error(tostring(result), 2)
	end

	activeRuntime = runtime
	activeOrder = order

	return Rivet
end

--[=[
	@param selfOrId Rivet | string
	@param id string?
	@return UnitContext

	Returns a started unit by id. Supports `Rivet.Get(id)` and `Rivet:Get(id)`.
]=]
function Rivet.Get(selfOrId: Types.Rivet | string, id: string?): Types.UnitContext
	if activeRuntime == nil then
		error("Rivet has not started; call Rivet.Start(config) before Rivet:Get(id)", 2)
	end

	local unitId: string?

	if type(selfOrId) == "string" then
		unitId = selfOrId
	else
		unitId = id
	end

	if type(unitId) ~= "string" or unitId == "" then
		error("Rivet.Get expects a non-empty unit id", 2)
	end

	return activeRuntime:Get(unitId)
end

--[=[
	Destroys the active runtime if one is running.
]=]
function Rivet.Destroy()
	local runtime = activeRuntime
	local order = activeOrder

	if runtime == nil or order == nil then
		return
	end

	activeRuntime = nil
	activeOrder = nil

	local destroySuccess, destroyResult = pcall(function()
		runtime:Destroy(order)
	end)
	local pluginSuccess, pluginResult = pcall(function()
		Plugins.Fire("OnDestroy")
	end)

	Plugins.Unlock()

	if not destroySuccess then
		error(tostring(destroyResult), 2)
	end

	if not pluginSuccess then
		error(tostring(pluginResult), 2)
	end
end

return Rivet
