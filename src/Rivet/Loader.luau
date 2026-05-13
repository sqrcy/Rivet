--!strict

--[=[
	@class Loader

	Discovers and validates Rivet unit ModuleScripts from configured roots.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

-- Constants

local Surfaces = require(script.Parent.Surfaces)

-- Private helpers

local function getInstancePath(instance: Instance): string
	local success, result = pcall(function()
		return instance:GetFullName()
	end)

	if success and type(result) == "string" then
		return result
	end

	return instance.Name
end

local function validateArrayIndex(owner: string, key: unknown)
	if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
		error(`{owner} must be an array`, 3)
	end
end

local function validateNoArrayHoles<T>(owner: string, values: { T }, count: number, maxIndex: number)
	if count ~= maxIndex then
		error(`{owner} must not contain holes`, 3)
	end

	for index = 1, maxIndex do
		if values[index] == nil then
			error(`{owner} must not contain holes`, 3)
		end
	end
end

local function normalizeRoots(config: unknown): Types.StartConfig
	if type(config) ~= "table" then
		error("Rivet.Start expects a config table", 3)
	end

	local rawConfig = config :: Internal.DynamicTable
	local rawRoots = rawConfig.Roots

	if type(rawRoots) ~= "table" then
		error("Rivet.Start requires config.Roots to be an array of Instances", 3)
	end

	local roots: { Instance } = {}
	local count = 0
	local maxIndex = 0

	for key, value in pairs(rawRoots :: Internal.DynamicTable) do
		validateArrayIndex("Rivet.Start config.Roots", key)

		local index = key :: number
		count += 1
		maxIndex = math.max(maxIndex, index)

		if typeof(value) ~= "Instance" then
			error(`Rivet.Start config.Roots[{index}] must be an Instance`, 3)
		end

		roots[index] = value :: Instance
	end

	validateNoArrayHoles("Rivet.Start config.Roots", roots, count, maxIndex)

	local debugConfig: Types.DebugConfig? = nil
	local rawDebug = rawConfig.Debug

	if rawDebug ~= nil then
		if type(rawDebug) ~= "table" then
			error("Rivet.Start config.Debug must be a table when provided", 3)
		end

		local debug = rawDebug :: Internal.DynamicTable

		if debug.Network ~= nil and type(debug.Network) ~= "boolean" then
			error("Rivet.Start config.Debug.Network must be a boolean when provided", 3)
		end

		debugConfig = {
			Network = debug.Network,
		}
	end

	return {
		Roots = roots,
		Debug = debugConfig,
	}
end

local function normalizeDependencies(
	rawUnit: Internal.DynamicTable,
	sourcePath: string,
	id: string
): { string }
	local rawDependencies = rawUnit.Dependencies

	if rawDependencies == nil then
		return {}
	end

	if type(rawDependencies) ~= "table" then
		error(`Rivet unit "{id}" at "{sourcePath}" Dependencies must be an array of strings`, 3)
	end

	local dependencies: { string } = {}
	local count = 0
	local maxIndex = 0

	for key, value in pairs(rawDependencies :: Internal.DynamicTable) do
		validateArrayIndex(`Rivet unit "{id}" Dependencies`, key)

		local index = key :: number
		count += 1
		maxIndex = math.max(maxIndex, index)

		if type(value) ~= "string" or value == "" then
			error(`Rivet unit "{id}" Dependencies[{index}] must be a non-empty string`, 3)
		end

		dependencies[index] = value
	end

	validateNoArrayHoles(`Rivet unit "{id}" Dependencies`, dependencies, count, maxIndex)

	return dependencies
end

local function validateLifecycleMethod(
	rawUnit: Internal.DynamicTable,
	sourcePath: string,
	id: string,
	methodName: string
)
	local method = rawUnit[methodName]

	if method ~= nil and type(method) ~= "function" then
		error(`Rivet unit "{id}" at "{sourcePath}" {methodName} must be a function`, 3)
	end
end

local function loadUnit(moduleScript: ModuleScript): Types.UnitRecord
	local sourcePath = getInstancePath(moduleScript)
	local success, result = pcall(require, moduleScript)

	if not success then
		error(`Rivet failed to require unit "{sourcePath}": {tostring(result)}`, 3)
	end

	if type(result) ~= "table" then
		error(`Rivet unit "{sourcePath}" must return a table`, 3)
	end

	local rawUnit = result :: Internal.DynamicTable
	local rawId = rawUnit.Id
	local id: string

	if rawId == nil then
		id = moduleScript.Name
	elseif type(rawId) == "string" and rawId ~= "" then
		id = rawId
	else
		error(`Rivet unit at "{sourcePath}" Id must be a non-empty string`, 3)
	end

	local dependencies = normalizeDependencies(rawUnit, sourcePath, id)
	local surfaces = Surfaces.Normalize(rawUnit, id, sourcePath)

	validateLifecycleMethod(rawUnit, sourcePath, id, "Init")
	validateLifecycleMethod(rawUnit, sourcePath, id, "Start")
	validateLifecycleMethod(rawUnit, sourcePath, id, "Destroy")

	rawUnit.Id = id
	rawUnit.Dependencies = dependencies
	rawUnit.Surfaces = surfaces

	return {
		Id = id,
		Dependencies = dependencies,
		Surfaces = surfaces,
		Module = moduleScript,
		SourcePath = sourcePath,
		Unit = rawUnit :: Types.UnitContext,
	}
end

local function collectModuleScripts(root: Instance, output: { ModuleScript })
	if root:IsA("ModuleScript") then
		table.insert(output, root :: ModuleScript)
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("ModuleScript") then
			table.insert(output, descendant :: ModuleScript)
		end
	end
end

-- Public API

local Loader = {}

--[=[
	@param config unknown
	@return StartConfig

	Validates and normalizes a Rivet start config.
]=]
function Loader.ValidateConfig(config: unknown): Types.StartConfig
	return normalizeRoots(config)
end

--[=[
	@param config StartConfig
	@return {UnitRecord}

	Loads all unit modules under the configured roots.
]=]
function Loader.Load(config: Types.StartConfig): { Types.UnitRecord }
	local moduleScripts: { ModuleScript } = {}

	for _, root in ipairs(config.Roots) do
		collectModuleScripts(root, moduleScripts)
	end

	local records: { Types.UnitRecord } = {}

	for _, moduleScript in ipairs(moduleScripts) do
		table.insert(records, loadUnit(moduleScript))
	end

	return records
end

return Loader
