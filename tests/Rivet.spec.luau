--!strict

--[=[
	@class RivetSpec

	Tests for Rivet v0.1 runtime behavior.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)

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

	describe("Rivet.Start", function()
		it("boots units in dependency order and runs Init before Start", function()
			startWithRoot(Fixtures.Ordered.Units)

			expect(TestState.Events[1]).to.equal("Data.Init")
			expect(TestState.Events[2]).to.equal("Inventory.Init")
			expect(TestState.Events[3]).to.equal("Data.Start")
			expect(TestState.Events[4]).to.equal("Inventory.Start")
		end)

		it("defaults unit Id to the ModuleScript name", function()
			startWithRoot(Fixtures.DefaultId.Units)

			local unit = Rivet:Get("DefaultNamed")

			expect(unit.Id).to.equal("DefaultNamed")
			expect(TestState.Events[1]).to.equal("DefaultNamed.Init")
		end)

		it("supports Rivet:Get after start", function()
			startWithRoot(Fixtures.Ordered.Units)

			local data = Rivet:Get("Data")

			expect(data.Id).to.equal("Data")
		end)

		it("supports Rivet.Get after start", function()
			startWithRoot(Fixtures.Ordered.Units)

			local data = Rivet.Get("Data")

			expect(data.Id).to.equal("Data")
		end)

		it("supports self:Get inside units", function()
			startWithRoot(Fixtures.Ordered.Units)

			local data = Rivet:Get("Data")
			local inventory = Rivet:Get("Inventory")

			expect(inventory.Data).to.equal(data)
		end)

		it("gives every unit a Clean object", function()
			startWithRoot(Fixtures.Ordered.Units)

			local data = Rivet:Get("Data")

			expect(type(data.Clean.Add)).to.equal("function")
			expect(type(data.Clean.Cleanup)).to.equal("function")
		end)

		it("does not load passive modules outside configured roots", function()
			startWithRoot(Fixtures.Passive.UnitRoot)

			expect(TestState.PassiveRequired).to.equal(false)
		end)

		it("errors clearly for duplicate ids", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Duplicate.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Duplicate Rivet unit id")
			expectMessageContains(message, "Duplicate")
		end)

		it("errors clearly for missing dependencies", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.MissingDependency.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "depends on missing unit")
			expectMessageContains(message, "Ghost")
		end)

		it("errors clearly for circular dependencies", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.Circular.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Circular Rivet dependency detected")
			expectMessageContains(message, "A -> B -> C -> A")
		end)

		it("wraps require errors with module context", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.RequireError.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Rivet failed to require unit")
			expectMessageContains(message, "Broken")
		end)

		it("errors clearly when a unit returns the wrong type", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.InvalidReturn.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "must return a table")
		end)

		it("errors clearly for invalid dependency entries", function()
			local success, message = pcall(function()
				startWithRoot(Fixtures.InvalidDependencies.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Dependencies[1] must be a non-empty string")
		end)
	end)

	describe("Rivet lifecycle safety", function()
		it("errors clearly when Get is called before Start", function()
			local success, message = pcall(function()
				Rivet:Get("Data")
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Rivet has not started")
		end)

		it("errors clearly when Start is called twice before Destroy", function()
			startWithRoot(Fixtures.Ordered.Units)

			local success, message = pcall(function()
				startWithRoot(Fixtures.Ordered.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "Rivet has already started")
		end)

		it("can start again after Destroy", function()
			startWithRoot(Fixtures.Ordered.Units)
			Rivet.Destroy()
			TestState.Reset()

			startWithRoot(Fixtures.Ordered.Units)

			expect(TestState.Events[1]).to.equal("Data.Init")
		end)

		it("destroys units and cleanup tasks in reverse boot order", function()
			startWithRoot(Fixtures.Ordered.Units)
			TestState.Reset()

			Rivet.Destroy()

			expect(TestState.Events[1]).to.equal("Inventory.Destroy")
			expect(TestState.Events[2]).to.equal("Inventory.Clean")
			expect(TestState.Events[3]).to.equal("Data.Destroy")
			expect(TestState.Events[4]).to.equal("Data.Clean")
		end)
	end)

	describe("invalid config", function()
		it("errors when config is not a table", function()
			local startUnknown = Rivet.Start :: Internal.DynamicFunction
			local success, message = pcall(function()
				startUnknown(nil)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "expects a config table")
		end)

		it("errors when Roots is missing", function()
			local startUnknown = Rivet.Start :: Internal.DynamicFunction
			local success, message = pcall(function()
				startUnknown({})
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "requires config.Roots")
		end)

		it("errors when a root is not an Instance", function()
			local startUnknown = Rivet.Start :: Internal.DynamicFunction
			local success, message = pcall(function()
				startUnknown({
					Roots = { "not an instance" },
				})
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "config.Roots[1] must be an Instance")
		end)
	end)
end
