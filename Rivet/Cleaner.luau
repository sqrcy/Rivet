--!strict

local Cleaner = {}
Cleaner.__index = Cleaner

function Cleaner.new()
	return setmetatable({
		_tasks = {},
	}, Cleaner)
end

function Cleaner:Add(taskObject, CleanerupMethod)
	if taskObject == nil then
		error("Cannot add nil to Cleaner", 2)
	end

	table.insert(self._tasks, {
		Object = taskObject,
		Method = CleanerupMethod,
	})

	return taskObject
end

function Cleaner:Remove(taskObject)
	for index, task in ipairs(self._tasks) do
		if task.Object == taskObject then
			table.remove(self._tasks, index)
			return true
		end
	end

	return false
end

function Cleaner:Cleanup()
	for index = #self._tasks, 1, -1 do
		local task = self._tasks[index]
		self._tasks[index] = nil

		local object = task.Object
		local method = task.Method

		if method then
			object[method](object)
		elseif typeof(object) == "RBXScriptConnection" then
			object:Disconnect()
		elseif typeof(object) == "Instance" then
			object:Destroy()
		elseif type(object) == "function" then
			object()
		elseif type(object) == "table" then
			if type(object.Destroy) == "function" then
				object:Destroy()
			elseif type(object.Disconnect) == "function" then
				object:Disconnect()
			elseif type(object.Cleanerup) == "function" then
				object:Cleanerup()
			end
		end
	end
end

Cleaner.Destroy = Cleaner.Cleanup

return Cleaner
