--!strict

--[=[
	@class RunTests

	Command-line TestEZ runner for Rivet.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)
local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ) :: Internal.DynamicTable
local Tests = ReplicatedStorage.Tests

-- Public API

local results = TestEZ.TestBootstrap:run({ Tests }, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
	error(`Rivet tests failed with {results.failureCount} failure(s)`, 1)
end
