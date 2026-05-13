--!strict

--[=[
	@class Codec

	Registers explicit object codecs and applies them at Rivet network boundaries.
]=]

-- Types

local Types = require(script.Parent.Types)
local Contracts = require(script.Parent.Contracts)
local Internal = require(script.Parent.Types.Internal)

type CodecSelf = Types.CodecRegistry

-- Constants

local CODEC_MARKER = "__rivetCodec"
local CODEC_DATA = "Data"

-- State

local codecs: { [string]: Types.CodecDefinition } = {}

-- Private helpers

local function validateCodecId(id: unknown): string
	if type(id) ~= "string" or id == "" then
		error("Rivet codec id must be a non-empty string", 3)
	end

	return id
end

local function getCodec(id: string): Types.CodecDefinition?
	return codecs[id]
end

local function unsupportedValueKind(value: unknown): string?
	local valueType = typeof(value)

	if valueType == "function" or valueType == "thread" or valueType == "userdata" then
		return valueType
	end

	return nil
end

local function assertNetworkSafeValue(value: unknown, path: string, seen: { [unknown]: boolean })
	local unsupportedKind = unsupportedValueKind(value)

	if unsupportedKind ~= nil then
		error(`Rivet codec encode failed at {path}: unsupported {unsupportedKind} value`, 4)
	end

	if type(value) ~= "table" then
		return
	end

	local valueTable = value :: Internal.DynamicTable

	if seen[valueTable] then
		error(`Rivet codec encode failed at {path}: cyclic table value`, 4)
	end

	seen[valueTable] = true

	for key, childValue in pairs(valueTable) do
		local keyKind = unsupportedValueKind(key)

		if keyKind ~= nil then
			error(`Rivet codec encode failed at {path}: unsupported {keyKind} table key`, 4)
		end

		assertNetworkSafeValue(childValue, `{path}.{tostring(key)}`, seen)
	end

	seen[valueTable] = nil
end

local function validateCodecForContract(
	unitId: string,
	surface: Types.SurfaceRecord,
	contract: string?
)
	if contract == nil or Contracts.IsPrimitive(contract) then
		return
	end

	if getCodec(contract) == nil then
		error(
			`Rivet missing codec. Unit "{unitId}" surface "{surface.Name}" uses unsupported type "{contract}"; register a codec with Rivet.Codec:Register("{contract}", codec).`,
			3
		)
	end
end

local function encodeCustomValue(contract: string, value: unknown, context: string): unknown
	local codec = getCodec(contract)

	if codec == nil then
		error(`Rivet missing codec. {context} expected codec "{contract}"`, 4)
	end

	local success, result = xpcall(function()
		return codec.Encode(value)
	end, function(message)
		return tostring(message)
	end)

	if not success then
		error(`Rivet codec encode failed at {context}: {tostring(result)}`, 4)
	end

	assertNetworkSafeValue(result, context, {})

	local encoded: Internal.DynamicTable = {}

	encoded[CODEC_MARKER] = contract
	encoded[CODEC_DATA] = result

	return encoded
end

local function decodeCustomValue(contract: string, value: unknown, context: string): unknown
	local codec = getCodec(contract)

	if codec == nil then
		error(`Rivet missing codec. {context} expected codec "{contract}"`, 4)
	end

	if type(value) ~= "table" then
		error(`Rivet codec decode failed at {context}: expected encoded "{contract}" table`, 4)
	end

	local encoded = value :: Internal.DynamicTable

	if encoded[CODEC_MARKER] ~= contract then
		error(`Rivet codec decode failed at {context}: expected codec "{contract}"`, 4)
	end

	local success, result = xpcall(function()
		return codec.Decode(encoded[CODEC_DATA])
	end, function(message)
		return tostring(message)
	end)

	if not success then
		error(`Rivet codec decode failed at {context}: {tostring(result)}`, 4)
	end

	return result
end

local function encodeValue(contract: string?, value: unknown, context: string): unknown
	if contract == nil or Contracts.IsPrimitive(contract) then
		return value
	end

	return encodeCustomValue(contract, value, context)
end

local function decodeValue(contract: string?, value: unknown, context: string): unknown
	if contract == nil or Contracts.IsPrimitive(contract) then
		return value
	end

	return decodeCustomValue(contract, value, context)
end

local function transformTuple(
	unitId: string,
	surfaceName: string,
	label: string,
	contracts: { string }?,
	values: Types.ValueTuple,
	side: string,
	transform: (string?, unknown, string) -> unknown
): Types.ValueTuple
	if contracts == nil then
		return values
	end

	local transformed = {
		n = values.n,
	} :: Types.ValueTuple

	for index = 1, values.n do
		local contract = contracts[index]
		transformed[index] =
			transform(contract, values[index], `{unitId}.{surfaceName} {label} #{index} ({side})`)
	end

	return transformed
end

-- Public API

local Codec = {}

--[=[
	@param id string
	@param codec CodecDefinition

	Registers an explicit encoder/decoder pair.
]=]
function Codec.Register(_self: CodecSelf, id: string, codec: Types.CodecDefinition)
	local codecId = validateCodecId(id)

	if codecs[codecId] ~= nil then
		error(`Rivet duplicate codec id "{codecId}"`, 2)
	end

	if type(codec) ~= "table" then
		error(`Rivet codec "{codecId}" must be a table`, 2)
	end

	if type(codec.Encode) ~= "function" then
		error(`Rivet codec "{codecId}" Encode must be a function`, 2)
	end

	if type(codec.Decode) ~= "function" then
		error(`Rivet codec "{codecId}" Decode must be a function`, 2)
	end

	codecs[codecId] = codec
end

--[=[
	@param unitId string
	@param surface SurfaceRecord

	Ensures custom contract names have registered codecs before networking starts.
]=]
function Codec.ValidateSurfaceContracts(unitId: string, surface: Types.SurfaceRecord)
	validateCodecForContract(unitId, surface, surface.Returns)

	for _, contract in ipairs(surface.Args or {}) do
		validateCodecForContract(unitId, surface, contract)
	end

	for _, contract in ipairs(surface.Payload or {}) do
		validateCodecForContract(unitId, surface, contract)
	end
end

--[=[
	Encodes a runtime tuple for a remote boundary.
]=]
function Codec.EncodeTuple(
	unitId: string,
	surfaceName: string,
	label: string,
	contracts: { string }?,
	values: Types.ValueTuple,
	side: string
): Types.ValueTuple
	return transformTuple(unitId, surfaceName, label, contracts, values, side, encodeValue)
end

--[=[
	Decodes a runtime tuple for a remote boundary.
]=]
function Codec.DecodeTuple(
	unitId: string,
	surfaceName: string,
	label: string,
	contracts: { string }?,
	values: Types.ValueTuple,
	side: string
): Types.ValueTuple
	return transformTuple(unitId, surfaceName, label, contracts, values, side, decodeValue)
end

--[=[
	Encodes a single return value for a remote boundary.
]=]
function Codec.EncodeReturn(
	unitId: string,
	surfaceName: string,
	contract: string?,
	value: unknown,
	side: string
): unknown
	return encodeValue(contract, value, `{unitId}.{surfaceName} return ({side})`)
end

--[=[
	Decodes a single return value for a remote boundary.
]=]
function Codec.DecodeReturn(
	unitId: string,
	surfaceName: string,
	contract: string?,
	value: unknown,
	side: string
): unknown
	return decodeValue(contract, value, `{unitId}.{surfaceName} return ({side})`)
end

return Codec
