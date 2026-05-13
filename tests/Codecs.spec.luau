--!strict

--[=[
	@class CodecsSpec

	Tests for Rivet v0.4 codec registration and network object encoding.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Network = require(ReplicatedStorage.Rivet.Network)
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)

local Fixtures = script.Parent.Fixtures
local TestState = require(Fixtures.TestState)
local Item = require(Fixtures.Codecs.Item)

-- Private helpers

local function expectMessageContains(message: unknown, expected: string)
	expect(tostring(message):find(expected, 1, true) ~= nil).to.equal(true)
end

local function fakePlayer(): Player
	return ({
		Name = "TestPlayer",
	} :: any) :: Player
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

local function itemCodec()
	return {
		Encode = function(value: unknown): unknown
			local item = value :: Item.Item

			return {
				Id = item.Id,
				Count = item.Count,
			}
		end,

		Decode = function(data: unknown): unknown
			local encoded = data :: Internal.DynamicTable

			return Item.new(encoded.Id, encoded.Count)
		end,
	}
end

-- Tests

return function()
	beforeAll(function()
		Rivet.Codec:Register("Item", itemCodec())

		Rivet.Codec:Register("BrokenEncodeItem", {
			Encode = function(_value: unknown): unknown
				return {
					Unsupported = function() end,
				}
			end,

			Decode = function(data: unknown): unknown
				return data
			end,
		})

		Rivet.Codec:Register("BrokenDecodeItem", {
			Encode = function(value: unknown): unknown
				local item = value :: Item.Item

				return {
					Id = item.Id,
					Count = item.Count,
				}
			end,

			Decode = function(_data: unknown): unknown
				error("decode exploded")
			end,
		})
	end)

	beforeEach(function()
		Rivet.Destroy()
		TestState.Reset()
	end)

	afterEach(function()
		Rivet.Destroy()
		TestState.Reset()
	end)

	describe("registration", function()
		it("registers codecs and rejects duplicate ids", function()
			Rivet.Codec:Register("DuplicateItem", itemCodec())

			local success, message = pcall(function()
				Rivet.Codec:Register("DuplicateItem", itemCodec())
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "duplicate codec id")
			expectMessageContains(message, "DuplicateItem")
		end)

		it("errors clearly when a surface references a missing codec", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Codecs.MissingCodec)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "missing codec")
			expectMessageContains(message, "GhostItem")
		end)
	end)

	describe("network encoding", function()
		it("encodes Query returns and decodes objects for the client", function()
			startWithRoot(Fixtures.Codecs.Units)

			local remote = getRemote("CodecInventory", "GetItem") :: RemoteFunction
			local item = Network.DispatchQueryForTest(remote, fakePlayer()) :: Item.Item

			expect(item.Id).to.equal("Sword")
			expect(item.Count).to.equal(1)
		end)

		it("encodes Action args and decodes objects on the server", function()
			startWithRoot(Fixtures.Codecs.Units)

			local remote = getRemote("CodecInventory", "UseItem") :: RemoteEvent
			local item = Item.new("Potion", 3)

			Network.DispatchActionForTest(remote, fakePlayer(), item)

			local received = TestState.LastArgs[1] :: Item.Item

			expect(received.Id).to.equal("Potion")
			expect(received.Count).to.equal(3)
		end)

		it("encodes Signal payloads and decodes objects for the client", function()
			startWithRoot(Fixtures.Codecs.Units)

			local remote = getRemote("CodecInventory", "ItemAdded") :: RemoteEvent
			local inventory = Rivet:Get("CodecInventory")
			local signal = (inventory.Client :: any).ItemAdded

			Network.SetTestSignalSink(remote, function(_methodName, _player, args)
				TestState.LastArgs = args
			end)

			signal:FireAll(Item.new("Axe", 2))

			local received = TestState.LastArgs[1] :: Item.Item

			expect(received.Id).to.equal("Axe")
			expect(received.Count).to.equal(2)
		end)

		it("errors clearly when codec encoding produces unsupported values", function()
			startWithRoot(Fixtures.Codecs.EncodeFailure)

			local remote = getRemote("EncodeFailureCodec", "GetItem") :: RemoteFunction
			local success, message = pcall(function()
				Network.DispatchQueryForTest(remote, fakePlayer())
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "codec encode failed")
			expectMessageContains(message, "unsupported function value")
		end)

		it("errors clearly when codec decoding fails", function()
			startWithRoot(Fixtures.Codecs.DecodeFailure)

			local remote = getRemote("DecodeFailureCodec", "UseItem") :: RemoteEvent
			local success, message = pcall(function()
				Network.DispatchActionForTest(remote, fakePlayer(), Item.new("Sword", 1))
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "codec decode failed")
			expectMessageContains(message, "decode exploded")
		end)
	end)
end
