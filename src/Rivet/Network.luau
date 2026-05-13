--!strict

--[=[
	@class Network

	Registers Rivet Query, Action, and Signal surfaces.
]=]

-- Types

local Types = require(script.Parent.Types)
local Internal = require(script.Parent.Types.Internal)

type RemoteSurfaceBinding = {
	Record: Types.UnitRecord,
	Surface: Types.SurfaceRecord,
}
type SignalSink = (methodName: string, player: Player?, args: Types.ValueTuple) -> ()
type QueryDispatcher = (player: Player, args: Types.ValueTuple) -> ...unknown
type ActionDispatcher = (player: Player, args: Types.ValueTuple) -> ()
type DebugNetworkState = {
	Stats: Types.NetworkStats,
}

-- Constants

local Codec = require(script.Parent.Codec)
local Contracts = require(script.Parent.Contracts)
local Plugins = require(script.Parent.Plugins)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local REMOTE_ROOT_NAME = "RivetRemotes"
local KIND_VALUE_NAME = "__RivetKind"
local CONTRACTS_FOLDER_NAME = "__RivetContracts"
local ARGS_FOLDER_NAME = "Args"
local RETURNS_VALUE_NAME = "Returns"
local PAYLOAD_FOLDER_NAME = "Payload"

-- State

local testSignalSinks: { [RemoteEvent]: SignalSink } = {}
local testQueryDispatchers: { [RemoteFunction]: QueryDispatcher } = {}
local testActionDispatchers: { [RemoteEvent]: ActionDispatcher } = {}
local testRemoteBindings: { [Instance]: RemoteSurfaceBinding } = {}
local debugNetwork: DebugNetworkState? = nil

-- Private helpers

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)

	if existing ~= nil then
		if not existing:IsA("Folder") then
			error(`Rivet networking expected "{existing:GetFullName()}" to be a Folder`, 3)
		end

		return existing :: Folder
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	return folder
end

local function setKind(remote: Instance, kind: Types.SurfaceKind)
	local existing = remote:FindFirstChild(KIND_VALUE_NAME)

	if existing ~= nil then
		existing:Destroy()
	end

	local value = Instance.new("StringValue")
	value.Name = KIND_VALUE_NAME
	value.Value = kind
	value.Parent = remote
end

local function getKind(remote: Instance): Types.SurfaceKind?
	local value = remote:FindFirstChild(KIND_VALUE_NAME)

	if value == nil or not value:IsA("StringValue") then
		return nil
	end

	local kind = (value :: StringValue).Value

	if kind == "Query" or kind == "Action" or kind == "Signal" then
		return kind
	end

	return nil
end

local function writeContractList(parent: Instance, name: string, contracts: { string }?)
	if contracts == nil then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	for index, contract in ipairs(contracts) do
		local value = Instance.new("StringValue")
		value.Name = tostring(index)
		value.Value = contract
		value.Parent = folder
	end
end

local function setContracts(remote: Instance, surface: Types.SurfaceRecord)
	local existing = remote:FindFirstChild(CONTRACTS_FOLDER_NAME)

	if existing ~= nil then
		existing:Destroy()
	end

	if surface.Args == nil and surface.Returns == nil and surface.Payload == nil then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = CONTRACTS_FOLDER_NAME
	folder.Parent = remote

	writeContractList(folder, ARGS_FOLDER_NAME, surface.Args)
	writeContractList(folder, PAYLOAD_FOLDER_NAME, surface.Payload)

	if surface.Returns ~= nil then
		local returns = Instance.new("StringValue")
		returns.Name = RETURNS_VALUE_NAME
		returns.Value = surface.Returns
		returns.Parent = folder
	end
end

local function readContractList(parent: Instance?, name: string): { string }?
	if parent == nil then
		return nil
	end

	local folder = parent:FindFirstChild(name)

	if folder == nil then
		return nil
	end

	if not folder:IsA("Folder") then
		error(`Rivet networking expected "{folder:GetFullName()}" to be a Folder`, 3)
	end

	local contracts: { string } = {}

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("StringValue") then
			local index = tonumber(child.Name)

			if index ~= nil then
				contracts[index] = (child :: StringValue).Value
			end
		end
	end

	return contracts
end

local function readReturnContract(parent: Instance?): string?
	if parent == nil then
		return nil
	end

	local returns = parent:FindFirstChild(RETURNS_VALUE_NAME)

	if returns == nil then
		return nil
	end

	if not returns:IsA("StringValue") then
		error(`Rivet networking expected "{returns:GetFullName()}" to be a StringValue`, 3)
	end

	return (returns :: StringValue).Value
end

local function readSurfaceContracts(
	remote: Instance,
	surface: Types.SurfaceRecord
): Types.SurfaceRecord
	local folder = remote:FindFirstChild(CONTRACTS_FOLDER_NAME)

	if folder ~= nil and not folder:IsA("Folder") then
		error(`Rivet networking expected "{folder:GetFullName()}" to be a Folder`, 3)
	end

	return {
		Name = surface.Name,
		Kind = surface.Kind,
		Scope = surface.Scope,
		Args = readContractList(folder, ARGS_FOLDER_NAME),
		Returns = readReturnContract(folder),
		Payload = readContractList(folder, PAYLOAD_FOLDER_NAME),
	}
end

local function createRemote(unitFolder: Folder, surface: Types.SurfaceRecord): Instance
	local existing = unitFolder:FindFirstChild(surface.Name)

	if existing ~= nil then
		existing:Destroy()
	end

	local remote: Instance

	if surface.Kind == "Query" then
		remote = Instance.new("RemoteFunction")
	else
		remote = Instance.new("RemoteEvent")
	end

	remote.Name = surface.Name
	remote.Parent = unitFolder
	setKind(remote, surface.Kind)
	setContracts(remote, surface)

	return remote
end

local function packArgs(...: unknown): Types.ValueTuple
	return table.pack(...) :: Types.ValueTuple
end

local function unpackArgs(args: Types.ValueTuple): ...unknown
	return table.unpack(args, 1, args.n)
end

local function resetTestDispatchers()
	testSignalSinks = {}
	testQueryDispatchers = {}
	testActionDispatchers = {}
	testRemoteBindings = {}
end

local function ensureStats(unitId: string, surface: Types.SurfaceRecord): Types.NetworkSurfaceStats?
	local state = debugNetwork

	if state == nil then
		return nil
	end

	local unitStats = state.Stats[unitId]

	if unitStats == nil then
		unitStats = {}
		state.Stats[unitId] = unitStats
	end

	local surfaceStats = unitStats[surface.Name]

	if surfaceStats == nil then
		surfaceStats = {
			Kind = surface.Kind,
			Calls = 0,
			Failures = 0,
		}
		unitStats[surface.Name] = surfaceStats
	end

	return surfaceStats
end

local function registerDebugSurface(unitId: string, surface: Types.SurfaceRecord)
	if ensureStats(unitId, surface) ~= nil then
		print(`Rivet debug network registered {unitId}.{surface.Name} ({surface.Kind})`)
	end
end

local function recordDebugCall(unitId: string, surface: Types.SurfaceRecord, args: Types.ValueTuple)
	Plugins.Fire("OnNetworkCall", {
		UnitId = unitId,
		SurfaceName = surface.Name,
		Kind = surface.Kind,
		ArgCount = args.n,
	})

	local stats = ensureStats(unitId, surface)

	if stats == nil then
		return
	end

	stats.Calls += 1
	print(`Rivet debug network call {unitId}.{surface.Name} ({surface.Kind})`)

	if args.n > 50 then
		warn(`Rivet debug network large payload for {unitId}.{surface.Name}: {args.n} values`)
	end
end

local function recordDebugFailure(unitId: string, surface: Types.SurfaceRecord, message: string)
	Plugins.Fire("OnNetworkError", {
		UnitId = unitId,
		SurfaceName = surface.Name,
		Kind = surface.Kind,
		Message = message,
	})

	local stats = ensureStats(unitId, surface)

	if stats == nil then
		return
	end

	stats.Failures += 1
	warn(`Rivet debug network failure {unitId}.{surface.Name}: {message}`)
end

local function rethrowNetworkFailure(
	operation: string,
	record: Types.UnitRecord,
	surface: Types.SurfaceRecord,
	message: unknown
): never
	local errorMessage = tostring(message)

	recordDebugFailure(record.Id, surface, errorMessage)

	if errorMessage:find("Rivet contract failed", 1, true) ~= nil then
		error(errorMessage, 3)
	end

	error(
		`Rivet {operation} failed. Unit "{record.Id}" surface "{surface.Name}": {errorMessage}`,
		3
	)
end

local function installQuery(
	record: Types.UnitRecord,
	surface: Types.SurfaceRecord,
	remote: RemoteFunction
)
	local method = record.Unit[surface.Name] :: Internal.DynamicFunction

	local function dispatch(player: Player, args: Types.ValueTuple): ...unknown
		recordDebugCall(record.Id, surface, args)

		local success, result = xpcall(function()
			local decodedArgs =
				Codec.DecodeTuple(record.Id, surface.Name, "arg", surface.Args, args, "server")

			Contracts.ValidateTuple(
				record.Id,
				surface.Name,
				"arg",
				surface.Args,
				decodedArgs,
				"server"
			)

			local value = method(record.Unit, player, unpackArgs(decodedArgs))

			Contracts.ValidateReturn(record.Id, surface.Name, surface.Returns, value, "server")

			return Codec.EncodeReturn(record.Id, surface.Name, surface.Returns, value, "server")
		end, function(message)
			return tostring(message)
		end)

		if not success then
			rethrowNetworkFailure("Query", record, surface, result)
		end

		return result
	end

	testQueryDispatchers[remote] = dispatch
	testRemoteBindings[remote] = {
		Record = record,
		Surface = surface,
	}
	remote.OnServerInvoke = function(player: Player, ...: unknown): ...unknown
		return dispatch(player, packArgs(...))
	end
end

local function installAction(
	record: Types.UnitRecord,
	surface: Types.SurfaceRecord,
	remote: RemoteEvent
)
	local method = record.Unit[surface.Name] :: Internal.DynamicFunction

	local function dispatch(player: Player, args: Types.ValueTuple)
		recordDebugCall(record.Id, surface, args)

		local success, result = xpcall(function()
			local decodedArgs =
				Codec.DecodeTuple(record.Id, surface.Name, "arg", surface.Args, args, "server")

			Contracts.ValidateTuple(
				record.Id,
				surface.Name,
				"arg",
				surface.Args,
				decodedArgs,
				"server"
			)
			method(record.Unit, player, unpackArgs(decodedArgs))
		end, function(message)
			return tostring(message)
		end)

		if not success then
			rethrowNetworkFailure("Action", record, surface, result)
		end
	end

	testActionDispatchers[remote] = dispatch
	testRemoteBindings[remote] = {
		Record = record,
		Surface = surface,
	}
	remote.OnServerEvent:Connect(function(player: Player, ...: unknown)
		dispatch(player, packArgs(...))
	end)
end

local function installSignal(
	record: Types.UnitRecord,
	surface: Types.SurfaceRecord,
	remote: RemoteEvent
)
	local client = record.Unit.Client

	if client == nil then
		client = {}
		record.Unit.Client = client
	end

	local clientMap = client :: { [string]: unknown }

	local function dispatchSignal(methodName: string, player: Player?, args: Types.ValueTuple)
		recordDebugCall(record.Id, surface, args)

		local success, result = xpcall(function()
			Contracts.ValidateTuple(
				record.Id,
				surface.Name,
				"payload",
				surface.Payload,
				args,
				"server"
			)

			return Codec.EncodeTuple(
				record.Id,
				surface.Name,
				"payload",
				surface.Payload,
				args,
				"server"
			)
		end, function(message)
			return tostring(message)
		end)

		if not success then
			rethrowNetworkFailure("Signal", record, surface, result)
		end

		local encodedPayload = result :: Types.ValueTuple
		local sink = testSignalSinks[remote]

		if sink ~= nil then
			local decodedPayload = Codec.DecodeTuple(
				record.Id,
				surface.Name,
				"payload",
				surface.Payload,
				encodedPayload,
				"client"
			)

			sink(methodName, player, decodedPayload)
			return
		end

		if methodName == "Fire" then
			remote:FireClient(player :: Player, unpackArgs(encodedPayload))
		elseif methodName == "FireAll" then
			remote:FireAllClients(unpackArgs(encodedPayload))
		else
			local exceptPlayer = player :: Player

			for _, currentPlayer in ipairs(Players:GetPlayers()) do
				if currentPlayer ~= exceptPlayer then
					remote:FireClient(currentPlayer, unpackArgs(encodedPayload))
				end
			end
		end
	end

	clientMap[surface.Name] = {
		Fire = function(_self: unknown, player: Player, ...: unknown)
			dispatchSignal("Fire", player, packArgs(...))
		end,

		FireAll = function(_self: unknown, ...: unknown)
			dispatchSignal("FireAll", nil, packArgs(...))
		end,

		FireExcept = function(_self: unknown, exceptPlayer: Player, ...: unknown)
			dispatchSignal("FireExcept", exceptPlayer, packArgs(...))
		end,
	}

	testRemoteBindings[remote] = {
		Record = record,
		Surface = surface,
	}
end

local function createClientProxy(unitFolder: Folder): Types.UnitContext
	local proxy = {
		Id = unitFolder.Name,
		Dependencies = {},
		Surfaces = {
			Client = {},
			Shared = {},
		},
		Clean = nil,
		Get = function()
			error("Rivet client network proxies cannot resolve dependencies", 2)
		end,
	} :: Internal.DynamicTable

	for _, child in ipairs(unitFolder:GetChildren()) do
		local kind = getKind(child)

		if kind == nil then
			continue
		end

		local surfaceKind: Types.SurfaceKind

		if kind == "Query" then
			surfaceKind = "Query"
		elseif kind == "Action" then
			surfaceKind = "Action"
		else
			surfaceKind = "Signal"
		end

		local baseSurface: Types.SurfaceRecord = {
			Name = child.Name,
			Kind = surfaceKind,
			Scope = "Client",
		}
		local surface = readSurfaceContracts(child, baseSurface)

		proxy.Surfaces.Client[child.Name] = surface

		if kind == "Query" then
			local remote = child :: RemoteFunction
			proxy[child.Name] = function(_self: unknown, ...: unknown): ...unknown
				local encodedArgs = Codec.EncodeTuple(
					proxy.Id,
					child.Name,
					"arg",
					surface.Args,
					packArgs(...),
					"client"
				)
				local encodedResult = remote:InvokeServer(unpackArgs(encodedArgs))

				return Codec.DecodeReturn(
					proxy.Id,
					child.Name,
					surface.Returns,
					encodedResult,
					"client"
				)
			end
		elseif kind == "Action" then
			local remote = child :: RemoteEvent
			proxy[child.Name] = function(_self: unknown, ...: unknown)
				local encodedArgs = Codec.EncodeTuple(
					proxy.Id,
					child.Name,
					"arg",
					surface.Args,
					packArgs(...),
					"client"
				)

				remote:FireServer(unpackArgs(encodedArgs))
			end
		else
			local remote = child :: RemoteEvent
			proxy[child.Name] = {
				Connect = function(
					_self: unknown,
					callback: Internal.DynamicFunction
				): RBXScriptConnection
					return remote.OnClientEvent:Connect(function(...: unknown)
						local decodedPayload = Codec.DecodeTuple(
							proxy.Id,
							child.Name,
							"payload",
							surface.Payload,
							packArgs(...),
							"client"
						)

						callback(unpackArgs(decodedPayload))
					end)
				end,
			}
		end
	end

	return proxy :: Types.UnitContext
end

-- Public API

local Network = {}

--[=[
	@param runtime Runtime
	@param registry Registry
	@param config StartConfig

	Sets up server endpoints or client proxies for declared surfaces.
]=]
function Network.Setup(runtime: Types.Runtime, registry: Types.Registry, config: Types.StartConfig)
	local remoteRoot = ReplicatedStorage:FindFirstChild(REMOTE_ROOT_NAME)

	resetTestDispatchers()

	if config.Debug ~= nil and config.Debug.Network == true then
		debugNetwork = {
			Stats = {},
		}
	else
		debugNetwork = nil
	end

	if RunService:IsServer() then
		local root = getOrCreateFolder(ReplicatedStorage, REMOTE_ROOT_NAME)

		for _, id in ipairs(registry:Order()) do
			local record = registry:Get(id)

			if next(record.Surfaces.Client) == nil then
				continue
			end

			local unitFolder = getOrCreateFolder(root, record.Id)
			unitFolder:ClearAllChildren()
			record.Unit.Clean:Add(unitFolder)

			for _, surface in pairs(record.Surfaces.Client) do
				Codec.ValidateSurfaceContracts(record.Id, surface)

				local remote = createRemote(unitFolder, surface)

				registerDebugSurface(record.Id, surface)

				if surface.Kind == "Query" then
					installQuery(record, surface, remote :: RemoteFunction)
				elseif surface.Kind == "Action" then
					installAction(record, surface, remote :: RemoteEvent)
				else
					installSignal(record, surface, remote :: RemoteEvent)
				end
			end
		end
	elseif remoteRoot ~= nil then
		if not remoteRoot:IsA("Folder") then
			error(`Rivet networking expected "{REMOTE_ROOT_NAME}" to be a Folder`, 2)
		end

		for _, child in ipairs(remoteRoot:GetChildren()) do
			if child:IsA("Folder") then
				local proxy = createClientProxy(child :: Folder)
				runtime:AddProxy(proxy.Id, proxy)
			end
		end
	end
end

--[=[
	Internal test support for Open Cloud runs without live clients.
]=]
function Network.SetTestSignalSink(remote: RemoteEvent, sink: SignalSink?)
	if sink == nil then
		testSignalSinks[remote] = nil
	else
		testSignalSinks[remote] = sink
	end
end

--[=[
	Internal test support for Open Cloud runs without live clients.
]=]
function Network.DispatchQueryForTest(
	remote: RemoteFunction,
	player: Player,
	...: unknown
): ...unknown
	local dispatch = testQueryDispatchers[remote]

	if dispatch == nil then
		error(`Rivet test dispatch could not find query handler for "{remote:GetFullName()}"`, 2)
	end

	local binding = testRemoteBindings[remote]

	if binding == nil then
		error(`Rivet test dispatch could not find query metadata for "{remote:GetFullName()}"`, 2)
	end

	local encodedArgs = Codec.EncodeTuple(
		binding.Record.Id,
		binding.Surface.Name,
		"arg",
		binding.Surface.Args,
		packArgs(...),
		"client"
	)
	local encodedResult = dispatch(player, encodedArgs)

	return Codec.DecodeReturn(
		binding.Record.Id,
		binding.Surface.Name,
		binding.Surface.Returns,
		encodedResult,
		"client"
	)
end

--[=[
	Internal test support for Open Cloud runs without live clients.
]=]
function Network.DispatchActionForTest(remote: RemoteEvent, player: Player, ...: unknown)
	local dispatch = testActionDispatchers[remote]

	if dispatch == nil then
		error(`Rivet test dispatch could not find action handler for "{remote:GetFullName()}"`, 2)
	end

	local binding = testRemoteBindings[remote]

	if binding == nil then
		error(`Rivet test dispatch could not find action metadata for "{remote:GetFullName()}"`, 2)
	end

	local encodedArgs = Codec.EncodeTuple(
		binding.Record.Id,
		binding.Surface.Name,
		"arg",
		binding.Surface.Args,
		packArgs(...),
		"client"
	)

	dispatch(player, encodedArgs)
end

--[=[
	@return NetworkStats

	Returns a copy of current network debug counters.
]=]
function Network.GetNetworkStats(): Types.NetworkStats
	local state = debugNetwork
	local snapshot: Types.NetworkStats = {}

	if state == nil then
		return snapshot
	end

	for unitId, unitStats in pairs(state.Stats) do
		local copiedUnitStats: { [string]: Types.NetworkSurfaceStats } = {}
		snapshot[unitId] = copiedUnitStats

		for surfaceName, surfaceStats in pairs(unitStats) do
			copiedUnitStats[surfaceName] = {
				Kind = surfaceStats.Kind,
				Calls = surfaceStats.Calls,
				Failures = surfaceStats.Failures,
			}
		end
	end

	return snapshot
end

return Network
