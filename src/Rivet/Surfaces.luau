--!strict

--[=[
	@class Surfaces

	Parses and validates Rivet Unit surface metadata.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

-- Constants

local Contracts = require(script.Parent.Contracts)

local SUPPORTED_CLIENT_KINDS = {
	Query = true,
	Action = true,
	Signal = true,
}

-- Types

type ParsedClientSurface = {
	Kind: Types.SurfaceKind,
	Args: { string }?,
	Returns: string?,
	Payload: { string }?,
}

-- Private helpers

local function emptySurfaces(): Types.NormalizedSurfaces
	return {
		Client = {},
		Shared = {},
	}
end

local function getMethod(unit: Internal.DynamicTable, name: string): unknown
	return unit[name]
end

local function assertMethod(
	unit: Internal.DynamicTable,
	unitId: string,
	sourcePath: string,
	scope: string,
	name: string
)
	if type(getMethod(unit, name)) ~= "function" then
		error(
			`Rivet invalid surface. Unit "{unitId}" at "{sourcePath}" exposes {scope}.{name}, but method "{name}" does not exist`,
			3
		)
	end
end

local function assertNoUnsupportedContractFields(
	unitId: string,
	surfaceName: string,
	kind: Types.SurfaceKind,
	rawValue: Internal.DynamicTable
)
	if kind == "Query" then
		if rawValue.Payload ~= nil then
			error(
				`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} Query cannot define Payload`,
				3
			)
		end
	elseif kind == "Action" then
		if rawValue.Returns ~= nil or rawValue.Payload ~= nil then
			error(
				`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} Action can only define Args`,
				3
			)
		end
	elseif rawValue.Args ~= nil or rawValue.Returns ~= nil then
		error(
			`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} Signal can only define Payload`,
			3
		)
	end
end

local function parseClientSurface(
	unitId: string,
	surfaceName: string,
	rawValue: unknown
): ParsedClientSurface
	if type(rawValue) == "string" then
		if SUPPORTED_CLIENT_KINDS[rawValue] then
			return {
				Kind = rawValue :: Types.SurfaceKind,
			}
		end

		error(
			`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} has unknown kind "{rawValue}"`,
			3
		)
	end

	if type(rawValue) == "table" then
		local raw = rawValue :: Internal.DynamicTable
		local rawKind = raw.Kind

		if type(rawKind) == "string" and SUPPORTED_CLIENT_KINDS[rawKind] then
			local kind: Types.SurfaceKind

			if rawKind == "Query" then
				kind = "Query"
			elseif rawKind == "Action" then
				kind = "Action"
			else
				kind = "Signal"
			end

			local owner = `Unit "{unitId}" Client.{surfaceName}`

			assertNoUnsupportedContractFields(unitId, surfaceName, kind, raw)

			return {
				Kind = kind,
				Args = Contracts.NormalizeTuple(`{owner} Args`, raw.Args),
				Returns = Contracts.NormalizeSingle(`{owner} Returns`, raw.Returns),
				Payload = Contracts.NormalizeTuple(`{owner} Payload`, raw.Payload),
			}
		end

		error(
			`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} has unknown or missing Kind`,
			3
		)
	end

	error(
		`Rivet invalid surface. Unit "{unitId}" Client.{surfaceName} must be a kind string or table`,
		3
	)
end

local function addSurface(
	surfaces: Types.NormalizedSurfaces,
	seenNames: { [string]: string },
	unitId: string,
	record: Types.SurfaceRecord
)
	local previousScope = seenNames[record.Name]

	if previousScope ~= nil then
		error(
			`Rivet invalid surface. Unit "{unitId}" exposes duplicate surface name "{record.Name}" in {previousScope} and {record.Scope}`,
			3
		)
	end

	seenNames[record.Name] = record.Scope
	surfaces[record.Scope][record.Name] = record
end

local function parseClientSurfaces(
	surfaces: Types.NormalizedSurfaces,
	seenNames: { [string]: string },
	unit: Internal.DynamicTable,
	unitId: string,
	sourcePath: string,
	rawClient: unknown
)
	if rawClient == nil then
		return
	end

	if type(rawClient) ~= "table" then
		error(`Rivet invalid surface. Unit "{unitId}" Client surfaces must be a table`, 3)
	end

	for name, rawValue in pairs(rawClient :: Internal.DynamicTable) do
		if type(name) ~= "string" or name == "" then
			error(
				`Rivet invalid surface. Unit "{unitId}" Client surface names must be non-empty strings`,
				3
			)
		end

		local surfaceName = name :: string
		local parsed = parseClientSurface(unitId, surfaceName, rawValue)

		if parsed.Kind == "Query" or parsed.Kind == "Action" then
			assertMethod(unit, unitId, sourcePath, "Client", surfaceName)
		end

		addSurface(surfaces, seenNames, unitId, {
			Name = surfaceName,
			Kind = parsed.Kind,
			Scope = "Client",
			Args = parsed.Args,
			Returns = parsed.Returns,
			Payload = parsed.Payload,
		})
	end
end

local function parseSharedSurfaces(
	surfaces: Types.NormalizedSurfaces,
	seenNames: { [string]: string },
	unit: Internal.DynamicTable,
	unitId: string,
	sourcePath: string,
	rawShared: unknown
)
	if rawShared == nil then
		return
	end

	if type(rawShared) ~= "table" then
		error(
			`Rivet invalid surface. Unit "{unitId}" Shared surfaces must be an array of method names`,
			3
		)
	end

	local normalizedShared = rawShared :: Internal.DynamicTable
	local sawNormalizedRecord = false

	for key, value in pairs(normalizedShared) do
		if type(key) == "string" and type(value) == "table" then
			local rawRecord = value :: Internal.DynamicTable

			if
				rawRecord.Name == key
				and rawRecord.Scope == "Shared"
				and rawRecord.Kind == "Query"
			then
				sawNormalizedRecord = true
			else
				sawNormalizedRecord = false
				break
			end
		else
			sawNormalizedRecord = false
			break
		end
	end

	if sawNormalizedRecord then
		for name in pairs(normalizedShared) do
			local surfaceName = name :: string

			assertMethod(unit, unitId, sourcePath, "Shared", surfaceName)
			addSurface(surfaces, seenNames, unitId, {
				Name = surfaceName,
				Kind = "Query",
				Scope = "Shared",
			})
		end

		return
	end

	local count = 0
	local maxIndex = 0

	for key, value in pairs(normalizedShared) do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			error(`Rivet invalid surface. Unit "{unitId}" Shared surfaces must be an array`, 3)
		end

		local index = key :: number
		count += 1
		maxIndex = math.max(maxIndex, index)

		if type(value) ~= "string" or value == "" then
			error(
				`Rivet invalid surface. Unit "{unitId}" Shared[{index}] must be a non-empty method name`,
				3
			)
		end

		assertMethod(unit, unitId, sourcePath, "Shared", value)
		addSurface(surfaces, seenNames, unitId, {
			Name = value,
			Kind = "Query",
			Scope = "Shared",
		})
	end

	if count ~= maxIndex then
		error(`Rivet invalid surface. Unit "{unitId}" Shared surfaces must not contain holes`, 3)
	end
end

-- Public API

local Surfaces = {}

--[=[
	@param unit table
	@param unitId string
	@param sourcePath string
	@return NormalizedSurfaces

	Normalizes optional Unit.Surfaces metadata.
]=]
function Surfaces.Normalize(
	unit: Internal.DynamicTable,
	unitId: string,
	sourcePath: string
): Types.NormalizedSurfaces
	local rawSurfaces = unit.Surfaces
	local surfaces = emptySurfaces()

	if rawSurfaces == nil then
		return surfaces
	end

	if type(rawSurfaces) ~= "table" then
		error(`Rivet invalid surface. Unit "{unitId}" Surfaces must be a table`, 3)
	end

	local raw = rawSurfaces :: Internal.DynamicTable
	local seenNames: { [string]: string } = {}

	for key in pairs(raw) do
		if key ~= "Client" and key ~= "Shared" then
			error(
				`Rivet invalid surface. Unit "{unitId}" has unsupported surface scope "{tostring(
					key
				)}"`,
				3
			)
		end
	end

	parseClientSurfaces(surfaces, seenNames, unit, unitId, sourcePath, raw.Client)
	parseSharedSurfaces(surfaces, seenNames, unit, unitId, sourcePath, raw.Shared)

	return surfaces
end

return Surfaces
