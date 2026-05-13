--!strict

--[=[
	@class Clean

	A small cleanup utility used by Rivet units.

	Clean intentionally implements the minimal behavior Rivet needs: task
	registration, task removal, and reverse-order cleanup.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

type CleanupTask = {
	Object: unknown,
	MethodName: string?,
}

type CleanData = {
	_tasks: { CleanupTask },
}

type CleanSelf = CleanData & Types.Clean

-- Constants

local DEFAULT_METHOD_NAMES = {
	"Destroy",
	"Disconnect",
	"Cleanup",
}

-- Private helpers

local function callNamedMethod(object: unknown, methodName: string)
	local dynamicObject = object :: Internal.DynamicTable
	local method = dynamicObject[methodName]

	if type(method) ~= "function" then
		error(`Rivet Clean task does not have method "{methodName}"`, 3)
	end

	(method :: Internal.DynamicFunction)(object)
end

local function cleanupObject(object: unknown, methodName: string?)
	if methodName ~= nil then
		callNamedMethod(object, methodName)
		return
	end

	local objectKind = typeof(object)

	if type(object) == "function" then
		(object :: () -> ())()
	elseif objectKind == "RBXScriptConnection" then
		(object :: RBXScriptConnection):Disconnect()
	elseif objectKind == "Instance" then
		(object :: Instance):Destroy()
	elseif type(object) == "table" then
		for _, defaultMethodName in ipairs(DEFAULT_METHOD_NAMES) do
			local dynamicObject = object :: Internal.DynamicTable

			if type(dynamicObject[defaultMethodName]) == "function" then
				callNamedMethod(object, defaultMethodName)
				return
			end
		end

		error("Rivet Clean table task must define Destroy, Disconnect, or Cleanup", 3)
	else
		error(`Rivet Clean cannot clean object of type "{objectKind}"`, 3)
	end
end

-- Public API

local Clean = {}
Clean.__index = Clean

--[=[
	@return Clean

	Constructs a new cleaner.
]=]
function Clean.new(): Types.Clean
	local self = (setmetatable({
		_tasks = {},
	}, Clean) :: unknown) :: CleanSelf

	return self
end

--[=[
	@param object T
	@param methodName string?
	@return T

	Adds an object to be cleaned later.
]=]
function Clean.Add<T>(self: CleanSelf, object: T, methodName: string?): T
	if object == nil then
		error("Rivet Clean:Add cannot add nil", 2)
	end

	if methodName ~= nil and methodName == "" then
		error("Rivet Clean:Add methodName cannot be empty", 2)
	end

	table.insert(self._tasks, {
		Object = object,
		MethodName = methodName,
	})

	return object
end

--[=[
	@param object unknown
	@return boolean

	Removes a pending cleanup task without running it.
]=]
function Clean.Remove(self: CleanSelf, object: unknown): boolean
	for index, task in ipairs(self._tasks) do
		if task.Object == object then
			table.remove(self._tasks, index)
			return true
		end
	end

	return false
end

--[=[
	Runs all pending cleanup tasks in reverse insertion order.
]=]
function Clean.Cleanup(self: CleanSelf)
	local firstFailure: string? = nil

	for index = #self._tasks, 1, -1 do
		local task = self._tasks[index]
		self._tasks[index] = nil

		local success, result = xpcall(function()
			cleanupObject(task.Object, task.MethodName)
		end, function(message)
			return tostring(message)
		end)

		if not success and firstFailure == nil then
			firstFailure = tostring(result)
		end
	end

	if firstFailure ~= nil then
		error(`Rivet Clean cleanup failed: {firstFailure}`, 2)
	end
end

Clean.Destroy = Clean.Cleanup

return Clean
