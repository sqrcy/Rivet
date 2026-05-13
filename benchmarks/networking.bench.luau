--!strict

--[=[
	@class NetworkingBenchmark

	Benchmark scaffold for Rivet network dispatch overhead.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Network = require(ReplicatedStorage.Rivet.Network)

-- Private helpers

local function fakePlayer(): Player
	return ({
		Name = "BenchmarkPlayer",
	} :: unknown) :: Player
end

-- Public API

Rivet.Start({
	Roots = {
		ReplicatedStorage.ExampleUnits,
	},
})

local remoteRoot = ReplicatedStorage:FindFirstChild("RivetRemotes")
assert(remoteRoot ~= nil, "Expected RivetRemotes")

local unitFolder = remoteRoot:FindFirstChild("Inventory")
assert(unitFolder ~= nil, "Expected Inventory remotes")

local remoteInstance = unitFolder:FindFirstChild("GetItems")
assert(remoteInstance ~= nil, "Expected Inventory.GetItems remote")

local remote = remoteInstance :: RemoteFunction

local startedAt = os.clock()

for _index = 1, 100 do
	Network.DispatchQueryForTest(remote, fakePlayer())
end

local elapsed = os.clock() - startedAt

Rivet.Destroy()

return {
	Name = "networking-query",
	Seconds = elapsed,
	Calls = 100,
}
