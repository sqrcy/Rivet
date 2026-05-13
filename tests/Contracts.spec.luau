--!strict

--[=[
	@class ContractsSpec

	Tests for Rivet v0.3 runtime contracts and network debug stats.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Network = require(ReplicatedStorage.Rivet.Network)

local Fixtures = script.Parent.Fixtures
local TestState = require(Fixtures.TestState)

-- Private helpers

local function expectMessageContains(message: unknown, expected: string)
	expect(tostring(message):find(expected, 1, true) ~= nil).to.equal(true)
end

local function startWithRoot(root: Instance)
	return Rivet.Start({
		Roots = { root },
	})
end

local function startWithNetworkDebug(root: Instance)
	return Rivet.Start({
		Roots = { root },
		Debug = {
			Network = true,
		},
	})
end

local function getRemote(unitId: string, surfaceName: string): Instance
	local remoteRoot = ReplicatedStorage:FindFirstChild("RivetRemotes")
	assert(remoteRoot ~= nil, "Expected RivetRemotes")

	local unitFolder = remoteRoot:FindFirstChild(unitId)
	assert(unitFolder ~= nil, `Expected remote folder for {unitId}`)

	local remote = unitFolder:FindFirstChild(surfaceName)
	assert(remote ~= nil, `Expected remote for {unitId}.{surfaceName}`)

	return remote
end

local function fakePlayer(): Player
	return ({
		Name = "TestPlayer",
	} :: any) :: Player
end

-- Tests

return function()
	beforeEach(function()
		Rivet.Destroy()
		TestState.Reset()
	end)

	afterEach(function()
		Rivet.Destroy()
		TestState.Reset()
	end)

	describe("runtime contracts", function()
		it("validates Query args and returns on success", function()
			startWithRoot(Fixtures.Contracts.Units)

			local player = fakePlayer()
			local remote = getRemote("ContractInventory", "GetItems") :: RemoteFunction
			local result = Network.DispatchQueryForTest(remote, player, "Weapons")

			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[1]).to.equal("Weapons")
			expect((result :: { string })[2]).to.equal("Sword")
		end)

		it("errors clearly when Query args fail validation", function()
			startWithRoot(Fixtures.Contracts.Units)

			local player = fakePlayer()
			local remote = getRemote("ContractInventory", "GetItems") :: RemoteFunction
			local success, message = pcall(function()
				Network.DispatchQueryForTest(remote, player, 10)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Rivet contract failed")
			expectMessageContains(message, "ContractInventory.GetItems")
			expectMessageContains(message, "arg #1 expected string, got number")
		end)

		it("errors clearly when Query returns fail validation", function()
			startWithRoot(Fixtures.Contracts.BadReturn)

			local remote = getRemote("BadReturnContract", "GetCount") :: RemoteFunction
			local success, message = pcall(function()
				Network.DispatchQueryForTest(remote, fakePlayer())
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "BadReturnContract.GetCount")
			expectMessageContains(message, "return expected number, got string")
		end)

		it("validates Action args on success", function()
			startWithRoot(Fixtures.Contracts.Units)

			local player = fakePlayer()
			local remote = getRemote("ContractInventory", "EquipItem") :: RemoteEvent

			Network.DispatchActionForTest(remote, player, "Sword")

			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[1]).to.equal("Sword")
		end)

		it("errors clearly when Action args fail validation", function()
			startWithRoot(Fixtures.Contracts.Units)

			local remote = getRemote("ContractInventory", "EquipItem") :: RemoteEvent
			local success, message = pcall(function()
				Network.DispatchActionForTest(remote, fakePlayer(), 10)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "ContractInventory.EquipItem")
			expectMessageContains(message, "arg #1 expected string, got number")
		end)

		it("validates Signal payloads on success", function()
			startWithRoot(Fixtures.Contracts.Units)

			local player = fakePlayer()
			local remote = getRemote("ContractInventory", "ItemAdded") :: RemoteEvent
			local inventory = Rivet:Get("ContractInventory")
			local signal = (inventory.Client :: any).ItemAdded

			Network.SetTestSignalSink(remote, function(methodName, signalPlayer, args)
				table.insert(TestState.SignalEvents, methodName)
				TestState.LastPlayer = signalPlayer
				TestState.LastArgs = args
			end)

			signal:Fire(player, "Sword", 1)

			expect(TestState.SignalEvents[1]).to.equal("Fire")
			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[2]).to.equal(1)
		end)

		it("errors clearly when Signal payloads fail validation", function()
			startWithRoot(Fixtures.Contracts.Units)

			local inventory = Rivet:Get("ContractInventory")
			local signal = (inventory.Client :: any).ItemAdded
			local success, message = pcall(function()
				signal:FireAll("Sword", "bad")
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "ContractInventory.ItemAdded")
			expectMessageContains(message, "payload #2 expected number, got string")
		end)

		it("does not validate omitted contracts", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local remote = getRemote("Inventory", "EquipItem") :: RemoteEvent

			Network.DispatchActionForTest(remote, fakePlayer(), 123)

			expect(TestState.LastArgs[1]).to.equal(123)
		end)

		it("allows any contracts", function()
			startWithRoot(Fixtures.Contracts.Units)

			local remote = getRemote("ContractInventory", "AnyValue") :: RemoteEvent
			local value = {
				Name = "Sword",
			}

			Network.DispatchActionForTest(remote, fakePlayer(), value)

			expect(TestState.LastArgs[1]).to.equal(value)
		end)

		it("rejects unsupported contract names clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Contracts.InvalidContract)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "unsupported type")
			expectMessageContains(message, "thread")
		end)
	end)

	describe("debug network stats", function()
		it("counts calls and failures when network debug is enabled", function()
			startWithNetworkDebug(Fixtures.Contracts.Units)

			local actionRemote = getRemote("ContractInventory", "EquipItem") :: RemoteEvent
			local queryRemote = getRemote("ContractInventory", "GetItems") :: RemoteFunction

			Network.DispatchActionForTest(actionRemote, fakePlayer(), "Sword")
			Network.DispatchQueryForTest(queryRemote, fakePlayer(), "Weapons")

			local failed = pcall(function()
				Network.DispatchActionForTest(actionRemote, fakePlayer(), 10)
			end)

			expect(failed).to.equal(false)

			local stats = Rivet.Debug:GetNetworkStats()

			expect(stats.ContractInventory.EquipItem.Kind).to.equal("Action")
			expect(stats.ContractInventory.EquipItem.Calls).to.equal(2)
			expect(stats.ContractInventory.EquipItem.Failures).to.equal(1)
			expect(stats.ContractInventory.GetItems.Calls).to.equal(1)
		end)

		it("returns an empty snapshot when network debug is disabled", function()
			startWithRoot(Fixtures.Contracts.Units)

			local remote = getRemote("ContractInventory", "EquipItem") :: RemoteEvent

			Network.DispatchActionForTest(remote, fakePlayer(), "Sword")

			local firstUnitId = next(Rivet.Debug:GetNetworkStats())

			expect(firstUnitId).to.equal(nil)
		end)
	end)

	describe("better errors", function()
		it("keeps dependency errors actionable", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.MissingDependency.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Rivet missing dependency")
			expectMessageContains(message, "Add a Unit with Id")
		end)
	end)
end
