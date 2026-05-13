--!strict

--[=[
	@class Runtime

	Owns prepared unit contexts and runs the Rivet lifecycle.
]=]

-- Types

local Types = require(script.Parent.Types)

-- Constants

local Clean = require(script.Parent.Clean)

-- Private helpers

local function callLifecycleMethod(
	record: Types.UnitRecord,
	methodName: "Init" | "Start" | "Destroy"
)
	local method = record.Unit[methodName]

	if method == nil then
		return
	end

	local success, result = xpcall(function()
		(method :: (Types.UnitContext) -> ())(record.Unit)
	end, function(message)
		return tostring(message)
	end)

	if not success then
		error(`Rivet unit "{record.Id}" {methodName} failed: {tostring(result)}`, 3)
	end
end

-- Public API

local Runtime = {}
Runtime.__index = Runtime

type RuntimeData = {
	_registry: Types.Registry,
	_proxies: { [string]: Types.UnitContext },
}

type RuntimeSelf = RuntimeData & Types.Runtime

--[=[
	@param registry Registry
	@return Runtime

	Constructs a runtime over a populated registry.
]=]
function Runtime.new(registry: Types.Registry): Types.Runtime
	local self = (
		setmetatable({
			_registry = registry,
			_proxies = {},
		}, Runtime) :: unknown
	) :: RuntimeSelf

	return self
end

--[=[
	@param record UnitRecord

	Attaches Rivet runtime services to a unit table.
]=]
function Runtime.Prepare(self: RuntimeSelf, record: Types.UnitRecord)
	record.Unit.Clean = Clean.new()
	record.Unit.Get = function(_unit: Types.UnitContext, id: string): Types.UnitContext
		return self:Get(id)
	end
end

--[=[
	@param id string
	@param proxy UnitContext

	Adds a client network proxy to runtime lookup.
]=]
function Runtime.AddProxy(self: RuntimeSelf, id: string, proxy: Types.UnitContext)
	self._proxies[id] = proxy
end

--[=[
	@param id string
	@return UnitContext

	Gets a prepared unit by id.
]=]
function Runtime.Get(self: RuntimeSelf, id: string): Types.UnitContext
	if self._registry:Has(id) then
		return self._registry:Get(id).Unit
	end

	local proxy = self._proxies[id]

	if proxy ~= nil then
		return proxy
	end

	error(`Unknown Rivet unit "{id}"`, 2)
end

--[=[
	@param order {string}

	Runs Init on all units in dependency order.
]=]
function Runtime.Init(
	self: RuntimeSelf,
	order: { string },
	onUnitInit: ((record: Types.UnitRecord) -> ())?
)
	for _, id in ipairs(order) do
		local record = self._registry:Get(id)

		callLifecycleMethod(record, "Init")

		if onUnitInit ~= nil then
			onUnitInit(record)
		end
	end
end

--[=[
	@param order {string}

	Runs Start on all units in dependency order.
]=]
function Runtime.Start(
	self: RuntimeSelf,
	order: { string },
	onUnitStart: ((record: Types.UnitRecord) -> ())?
)
	for _, id in ipairs(order) do
		local record = self._registry:Get(id)

		callLifecycleMethod(record, "Start")

		if onUnitStart ~= nil then
			onUnitStart(record)
		end
	end
end

--[=[
	@param order {string}

	Destroys units in reverse dependency order.
]=]
function Runtime.Destroy(self: RuntimeSelf, order: { string })
	local firstFailure: string? = nil

	for index = #order, 1, -1 do
		local id = order[index]
		local record = self._registry:Get(id)

		local destroySuccess, destroyResult = xpcall(function()
			callLifecycleMethod(record, "Destroy")
		end, function(message)
			return tostring(message)
		end)

		if not destroySuccess and firstFailure == nil then
			firstFailure = tostring(destroyResult)
		end

		local clean = record.Unit.Clean

		if clean ~= nil then
			local cleanSuccess, cleanResult = xpcall(function()
				clean:Cleanup()
			end, function(message)
				return tostring(message)
			end)

			if not cleanSuccess and firstFailure == nil then
				firstFailure = tostring(cleanResult)
			end
		end
	end

	if firstFailure ~= nil then
		error(`Rivet.Destroy failed: {firstFailure}`, 2)
	end
end

return Runtime
