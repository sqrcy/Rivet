--!strict

--[=[
	@class Registry

	Runtime registry for Rivet unit records.
]=]

-- Types

local Types = require(script.Parent.Types)

type RegistryData = {
	_records: { [string]: Types.UnitRecord },
	_order: { string },
}

type RegistrySelf = RegistryData & Types.Registry

-- Public API

local Registry = {}
Registry.__index = Registry

--[=[
	@return Registry

	Constructs an empty unit registry.
]=]
function Registry.new(): Types.Registry
	local self = (
		setmetatable({
			_records = {},
			_order = {},
		}, Registry) :: unknown
	) :: RegistrySelf

	return self
end

--[=[
	@param record UnitRecord

	Adds a unit record to the registry.
]=]
function Registry.Add(self: RegistrySelf, record: Types.UnitRecord)
	local existing = self._records[record.Id]

	if existing ~= nil then
		error(
			`Duplicate Rivet unit id "{record.Id}" from "{record.SourcePath}" conflicts with "{existing.SourcePath}"`,
			2
		)
	end

	self._records[record.Id] = record
	table.insert(self._order, record.Id)
end

--[=[
	@param id string
	@return UnitRecord

	Gets a unit record by id.
]=]
function Registry.Get(self: RegistrySelf, id: string): Types.UnitRecord
	local record = self._records[id]

	if record == nil then
		error(`Unknown Rivet unit "{id}"`, 2)
	end

	return record
end

--[=[
	@param id string
	@return boolean

	Returns whether a unit id exists in the registry.
]=]
function Registry.Has(self: RegistrySelf, id: string): boolean
	return self._records[id] ~= nil
end

--[=[
	@return {[string]: UnitRecord}

	Returns all records by id.
]=]
function Registry.All(self: RegistrySelf): { [string]: Types.UnitRecord }
	return self._records
end

--[=[
	@return {string}

	Returns unit ids in discovery order.
]=]
function Registry.Order(self: RegistrySelf): { string }
	return self._order
end

return Registry
