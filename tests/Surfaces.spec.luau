--!strict

--[=[
	@class SurfacesSpec

	Tests for Rivet v0.2 surface parsing and networking.
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

	describe("surface parsing", function()
		it("parses shorthand and expanded client surfaces", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local inventory = Rivet:Get("Inventory")

			expect(inventory.Surfaces.Client.GetItems.Kind).to.equal("Query")
			expect(inventory.Surfaces.Client.EquipItem.Kind).to.equal("Action")
			expect(inventory.Surfaces.Client.ItemAdded.Kind).to.equal("Signal")
		end)

		it("parses shared surfaces", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local inventory = Rivet:Get("Inventory")

			expect(inventory.Surfaces.Shared.CanStack.Name).to.equal("CanStack")
		end)

		it("rejects unknown surface kinds clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Surfaces.InvalidUnknownKind)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "unknown kind")
			expectMessageContains(message, "Stream")
		end)

		it("rejects missing Query methods clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Surfaces.InvalidMissingQuery)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Client.GetItems")
			expectMessageContains(message, "does not exist")
		end)

		it("rejects missing Action methods clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Surfaces.InvalidMissingAction)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Client.EquipItem")
			expectMessageContains(message, "does not exist")
		end)

		it("allows Signal surfaces without backing methods", function()
			startWithRoot(Fixtures.Surfaces.SignalOnly)

			local unit = Rivet:Get("SignalOnly")

			expect(unit.Surfaces.Client.ItemAdded.Kind).to.equal("Signal")
		end)

		it("rejects missing Shared methods clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Surfaces.InvalidMissingShared)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Shared.CanStack")
			expectMessageContains(message, "does not exist")
		end)

		it("rejects duplicate surface names clearly", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Surfaces.InvalidDuplicate)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "duplicate surface name")
			expectMessageContains(message, "CanStack")
		end)
	end)

	describe("networking", function()
		it("creates predictable remotes for declared Client surfaces", function()
			startWithRoot(Fixtures.Surfaces.Units)

			expect(getRemote("Inventory", "GetItems"):IsA("RemoteFunction")).to.equal(true)
			expect(getRemote("Inventory", "EquipItem"):IsA("RemoteEvent")).to.equal(true)
			expect(getRemote("Inventory", "ItemAdded"):IsA("RemoteEvent")).to.equal(true)
		end)

		it("does not expose Shared surfaces as remotes", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local remoteRoot = ReplicatedStorage:FindFirstChild("RivetRemotes")
			assert(remoteRoot ~= nil, "Expected RivetRemotes")

			local unitFolder = remoteRoot:FindFirstChild("Inventory")
			assert(unitFolder ~= nil, "Expected Inventory remote folder")

			expect(unitFolder:FindFirstChild("CanStack")).to.equal(nil)
		end)

		it("client Query reaches server method and passes Player", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local player = fakePlayer()
			local remote = getRemote("Inventory", "GetItems") :: RemoteFunction
			local result = { Network.DispatchQueryForTest(remote, player, "Weapons") }

			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[1]).to.equal("Weapons")
			expect((result[1] :: { string })[1]).to.equal("Weapons")
		end)

		it("client Action reaches server method without requiring a return", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local player = fakePlayer()
			local remote = getRemote("Inventory", "EquipItem") :: RemoteEvent

			Network.DispatchActionForTest(remote, player, "Sword")

			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[1]).to.equal("Sword")
			expect(TestState.Events[2]).to.equal("Inventory.EquipItem")
		end)

		it("server Signal fires to one client through the signal wrapper", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local player = fakePlayer()
			local remote = getRemote("Inventory", "ItemAdded") :: RemoteEvent
			local inventory = Rivet:Get("Inventory")
			local client = inventory.Client :: any
			local signal = client.ItemAdded

			Network.SetTestSignalSink(remote, function(methodName, signalPlayer, args)
				table.insert(TestState.SignalEvents, methodName)
				TestState.LastPlayer = signalPlayer
				TestState.LastArgs = args
			end)

			signal:Fire(player, "Sword")

			expect(TestState.SignalEvents[1]).to.equal("Fire")
			expect(TestState.LastPlayer).to.equal(player)
			expect(TestState.LastArgs[1]).to.equal("Sword")
		end)

		it("server Signal fires to all clients through the signal wrapper", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local remote = getRemote("Inventory", "ItemAdded") :: RemoteEvent
			local inventory = Rivet:Get("Inventory")
			local client = inventory.Client :: any
			local signal = client.ItemAdded

			Network.SetTestSignalSink(remote, function(methodName, signalPlayer, args)
				table.insert(TestState.SignalEvents, methodName)
				TestState.LastPlayer = signalPlayer
				TestState.LastArgs = args
			end)

			signal:FireAll("Sword")

			expect(TestState.SignalEvents[1]).to.equal("FireAll")
			expect(TestState.LastPlayer).to.equal(nil)
			expect(TestState.LastArgs[1]).to.equal("Sword")
		end)

		it("does not expose undeclared methods as remotes", function()
			startWithRoot(Fixtures.Surfaces.Units)

			local remoteRoot = ReplicatedStorage:FindFirstChild("RivetRemotes")
			assert(remoteRoot ~= nil, "Expected RivetRemotes")

			local unitFolder = remoteRoot:FindFirstChild("Inventory")
			assert(unitFolder ~= nil, "Expected Inventory remote folder")

			expect(unitFolder:FindFirstChild("Destroy")).to.equal(nil)
			expect(unitFolder:FindFirstChild("Init")).to.equal(nil)
		end)

		it("v0.1 units without surfaces still work", function()
			startWithRoot(Fixtures.Ordered.Units)

			expect(TestState.Events[1]).to.equal("Data.Init")
			expect(TestState.Events[2]).to.equal("Inventory.Init")
		end)
	end)
end
