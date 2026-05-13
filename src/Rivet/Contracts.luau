--!strict

--[=[
	@class Contracts

	Normalizes and validates optional Rivet runtime contract metadata.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

-- Constants

local SUPPORTED_CONTRACTS: { [string]: boolean } = {
	["nil"] = true,
	boolean = true,
	number = true,
	string = true,
	table = true,
	Instance = true,
	Player = true,
	Vector3 = true,
	CFrame = true,
	Color3 = true,
	EnumItem = true,
	buffer = true,
	any = true,
}

-- Private helpers

local function contractName(owner: string, rawValue: unknown): string
	if type(rawValue) ~= "string" or rawValue == "" then
		error(`Rivet invalid contract. {owner} must be a supported type name`, 3)
	end

	return rawValue
end

local function validateArrayIndex(owner: string, key: unknown)
	if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
		error(`Rivet invalid contract. {owner} must be an array`, 3)
	end
end

local function validateNoArrayHoles(
	owner: string,
	values: { string },
	count: number,
	maxIndex: number
)
	if count ~= maxIndex then
		error(`Rivet invalid contract. {owner} must not contain holes`, 3)
	end

	for index = 1, maxIndex do
		if values[index] == nil then
			error(`Rivet invalid contract. {owner} must not contain holes`, 3)
		end
	end
end

local function actualTypeOf(value: unknown): string
	if value == nil then
		return "nil"
	end

	local valueType = typeof(value)

	if valueType == "Instance" then
		local instance = value :: Instance

		if instance:IsA("Player") then
			return "Player"
		end
	end

	return valueType
end

local function matchesContract(expected: string, value: unknown): boolean
	if expected == "any" then
		return true
	end

	if expected == "nil" then
		return value == nil
	end

	if expected == "Player" then
		return typeof(value) == "Instance" and (value :: Instance):IsA("Player")
	end

	if SUPPORTED_CONTRACTS[expected] ~= true then
		return true
	end

	return actualTypeOf(value) == expected
end

-- Public API

local Contracts = {}

--[=[
	@param name string
	@return boolean

	Returns whether a contract name is a built-in primitive contract.
]=]
function Contracts.IsPrimitive(name: string): boolean
	return SUPPORTED_CONTRACTS[name] == true
end

--[=[
	@param owner string
	@param rawValue unknown
	@return string?

	Normalizes an optional single-value contract field.
]=]
function Contracts.NormalizeSingle(owner: string, rawValue: unknown): string?
	if rawValue == nil then
		return nil
	end

	return contractName(owner, rawValue)
end

--[=[
	@param owner string
	@param rawValue unknown
	@return {string}?

	Normalizes an optional tuple contract field.
]=]
function Contracts.NormalizeTuple(owner: string, rawValue: unknown): { string }?
	if rawValue == nil then
		return nil
	end

	if type(rawValue) ~= "table" then
		error(`Rivet invalid contract. {owner} must be an array of supported type names`, 3)
	end

	local contracts: { string } = {}
	local count = 0
	local maxIndex = 0

	for key, value in pairs(rawValue :: Internal.DynamicTable) do
		validateArrayIndex(owner, key)

		local index = key :: number
		count += 1
		maxIndex = math.max(maxIndex, index)
		contracts[index] = contractName(`{owner}[{index}]`, value)
	end

	validateNoArrayHoles(owner, contracts, count, maxIndex)

	return contracts
end

--[=[
	@param unitId string
	@param surfaceName string
	@param label string
	@param contracts {string}?
	@param values ValueTuple
	@param side string

	Validates a runtime argument or payload tuple against a contract.
]=]
function Contracts.ValidateTuple(
	unitId: string,
	surfaceName: string,
	label: string,
	contracts: { string }?,
	values: Types.ValueTuple,
	side: string
)
	if contracts == nil then
		return
	end

	local expectedCount = #contracts

	if values.n ~= expectedCount then
		error(
			`Rivet contract failed: {unitId}.{surfaceName} {label} count expected {expectedCount}, got {values.n} ({side})`,
			3
		)
	end

	for index, expected in ipairs(contracts) do
		local value = values[index]

		if not matchesContract(expected, value) then
			error(
				`Rivet contract failed: {unitId}.{surfaceName} {label} #{index} expected {expected}, got {actualTypeOf(
					value
				)} ({side})`,
				3
			)
		end
	end
end

--[=[
	@param unitId string
	@param surfaceName string
	@param contract string?
	@param value unknown
	@param side string

	Validates a runtime return value against a contract.
]=]
function Contracts.ValidateReturn(
	unitId: string,
	surfaceName: string,
	contract: string?,
	value: unknown,
	side: string
)
	if contract == nil then
		return
	end

	if not matchesContract(contract, value) then
		error(
			`Rivet contract failed: {unitId}.{surfaceName} return expected {contract}, got {actualTypeOf(
				value
			)} ({side})`,
			3
		)
	end
end

return Contracts
