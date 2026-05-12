--!strict

local Registry = {}
Registry.__index = Registry

function Registry.new()
	return setmetatable({
		_units = {},
		_order = {},
	}, Registry)
end

function Registry:Add(unit)
	if self._units[unit.Id] then
		error(`Duplicate Rivet unit id "{unit.Id}"`, 2)
	end

	self._units[unit.Id] = unit
	table.insert(self._order, unit.Id)
end

function Registry:Get(id)
	local unit = self._units[id]

	if not unit then
		error(`Unknown Rivet unit "{id}"`, 2)
	end

	return unit
end

function Registry:Has(id)
	return self._units[id] ~= nil
end

function Registry:All()
	return self._units
end

function Registry:Order()
	return self._order
end

return Registry