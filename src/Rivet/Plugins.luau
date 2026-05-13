--!strict

--[=[
	@class Plugins

	Registers optional Rivet plugins and runs plugin lifecycle hooks.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

type HookName =
	"Init"
	| "Start"
	| "OnUnitLoaded"
	| "OnUnitPrepared"
	| "OnUnitInit"
	| "OnUnitStart"
	| "OnSurfaceRegistered"
	| "OnNetworkCall"
	| "OnNetworkError"
	| "OnDestroy"

-- Constants

local HOOK_NAMES: { HookName } = {
	"Init",
	"Start",
	"OnUnitLoaded",
	"OnUnitPrepared",
	"OnUnitInit",
	"OnUnitStart",
	"OnSurfaceRegistered",
	"OnNetworkCall",
	"OnNetworkError",
	"OnDestroy",
}

-- State

local plugins: { Types.Plugin } = {}
local pluginIds: { [string]: boolean } = {}
local locked = false

-- Private helpers

local function validateHook(plugin: Internal.DynamicTable, pluginId: string, hookName: HookName)
	local hook = plugin[hookName]

	if hook ~= nil and type(hook) ~= "function" then
		error(`Rivet plugin "{pluginId}" {hookName} must be a function`, 3)
	end
end

local function callHook(plugin: Types.Plugin, hookName: HookName, ...: unknown)
	local rawPlugin = plugin :: Internal.DynamicTable
	local hook = rawPlugin[hookName]

	if hook == nil then
		return
	end

	local success, result = xpcall(function(...)
		(hook :: Internal.DynamicFunction)(plugin, ...)
	end, function(message)
		return tostring(message)
	end, ...)

	if not success then
		error(`Rivet plugin "{plugin.Id}" {hookName} failed: {tostring(result)}`, 3)
	end
end

-- Public API

local Plugins = {}

--[=[
	@param plugin unknown

	Registers a plugin before Rivet starts.
]=]
function Plugins.Register(plugin: unknown)
	if locked then
		error("Rivet plugins must be registered before Rivet.Start()", 3)
	end

	if type(plugin) ~= "table" then
		error("Rivet.Use expects a plugin table", 3)
	end

	local rawPlugin = plugin :: Internal.DynamicTable
	local rawId = rawPlugin.Id

	if type(rawId) ~= "string" or rawId == "" then
		error("Rivet plugin Id must be a non-empty string", 3)
	end

	local pluginId = rawId :: string

	if pluginIds[pluginId] then
		error(`Rivet duplicate plugin id "{pluginId}"`, 3)
	end

	for _, hookName in ipairs(HOOK_NAMES) do
		validateHook(rawPlugin, pluginId, hookName :: HookName)
	end

	pluginIds[pluginId] = true
	table.insert(plugins, rawPlugin :: Types.Plugin)
end

--[=[
	Prevents new plugins from being registered during an active runtime.
]=]
function Plugins.Lock()
	locked = true
end

--[=[
	Allows plugin registration after a failed or destroyed runtime.
]=]
function Plugins.Unlock()
	locked = false
end

--[=[
	Internal test support for deterministic plugin specs.
]=]
function Plugins.ResetForTest()
	plugins = {}
	pluginIds = {}
	locked = false
end

--[=[
	@param rivet Rivet

	Runs plugin Init lifecycle.
]=]
function Plugins.Init(rivet: Types.Rivet)
	for _, plugin in ipairs(plugins) do
		callHook(plugin, "Init", rivet)
	end
end

--[=[
	@param rivet Rivet

	Runs plugin Start lifecycle.
]=]
function Plugins.Start(rivet: Types.Rivet)
	for _, plugin in ipairs(plugins) do
		callHook(plugin, "Start", rivet)
	end
end

--[=[
	@param hookName HookName
	@param ... unknown

	Runs a plugin hook for every registered plugin.
]=]
function Plugins.Fire(hookName: HookName, ...: unknown)
	for _, plugin in ipairs(plugins) do
		callHook(plugin, hookName, ...)
	end
end

return Plugins
