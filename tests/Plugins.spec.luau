--!strict

--[=[
	@class PluginsSpec

	Tests for Rivet v0.5 plugin registration and hooks.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Plugins = require(ReplicatedStorage.Rivet.Plugins)
local Types = require(ReplicatedStorage.Rivet.Types)

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

local function hasEvent(events: { string }, expected: string): boolean
	for _, event in ipairs(events) do
		if event == expected then
			return true
		end
	end

	return false
end

-- Tests

return function()
	beforeEach(function()
		Rivet.Destroy()
		Plugins.ResetForTest()
		TestState.Reset()
	end)

	afterEach(function()
		Rivet.Destroy()
		Plugins.ResetForTest()
		TestState.Reset()
	end)

	describe("registration", function()
		it("registers plugins before startup", function()
			local plugin: Types.Plugin = {
				Id = "RegisterPlugin",
			}

			local result = Rivet.Use(plugin)

			expect(result).to.equal(Rivet)
		end)

		it("rejects duplicate plugin ids", function()
			local plugin: Types.Plugin = {
				Id = "DuplicatePlugin",
			}

			Rivet.Use(plugin)

			local success, message = pcall(function()
				Rivet.Use(plugin)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "duplicate plugin id")
			expectMessageContains(message, "DuplicatePlugin")
		end)

		it("rejects plugin registration after startup", function()
			startWithRoot(Fixtures.Ordered.Units)

			local success, message = pcall(function()
				local plugin: Types.Plugin = {
					Id = "LatePlugin",
				}

				Rivet.Use(plugin)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "registered before Rivet.Start")
		end)
	end)

	describe("lifecycle", function()
		it("calls plugin Init and Start", function()
			local events: { string } = {}
			local plugin: Types.Plugin = {
				Id = "LifecyclePlugin",
			}

			plugin.Init = function(_self: Types.Plugin)
				table.insert(events, "Plugin.Init")
			end

			plugin.Start = function(_self: Types.Plugin)
				table.insert(events, "Plugin.Start")
			end

			Rivet.Use(plugin)
			startWithRoot(Fixtures.Ordered.Units)

			expect(hasEvent(events, "Plugin.Init")).to.equal(true)
			expect(hasEvent(events, "Plugin.Start")).to.equal(true)
		end)

		it("calls unit hooks in the expected order", function()
			local events: { string } = {}
			local plugin: Types.Plugin = {
				Id = "UnitHookPlugin",
			}

			plugin.OnUnitLoaded = function(_self: Types.Plugin, unit: Types.UnitContext)
				table.insert(events, `Loaded:{unit.Id}`)
			end

			plugin.OnUnitPrepared = function(_self: Types.Plugin, unit: Types.UnitContext)
				table.insert(events, `Prepared:{unit.Id}`)
			end

			plugin.Init = function(_self: Types.Plugin)
				table.insert(events, "Plugin.Init")
			end

			plugin.OnUnitInit = function(_self: Types.Plugin, unit: Types.UnitContext)
				table.insert(events, `UnitInit:{unit.Id}`)
			end

			plugin.OnUnitStart = function(_self: Types.Plugin, unit: Types.UnitContext)
				table.insert(events, `UnitStart:{unit.Id}`)
			end

			plugin.Start = function(_self: Types.Plugin)
				table.insert(events, "Plugin.Start")
			end

			Rivet.Use(plugin)
			startWithRoot(Fixtures.Ordered.Units)

			expect(events[1]).to.equal("Loaded:Data")
			expect(events[2]).to.equal("Loaded:Inventory")
			expect(events[3]).to.equal("Prepared:Data")
			expect(events[4]).to.equal("Prepared:Inventory")
			expect(events[5]).to.equal("Plugin.Init")
			expect(events[6]).to.equal("UnitInit:Data")
			expect(events[7]).to.equal("UnitInit:Inventory")
			expect(events[8]).to.equal("UnitStart:Data")
			expect(events[9]).to.equal("UnitStart:Inventory")
			expect(events[10]).to.equal("Plugin.Start")
		end)

		it("calls surface registration hooks", function()
			local seen: { [string]: boolean } = {}
			local plugin: Types.Plugin = {
				Id = "SurfaceHookPlugin",
			}

			plugin.OnSurfaceRegistered = function(
				_self: Types.Plugin,
				unit: Types.UnitContext,
				surface: Types.SurfaceRecord
			)
				seen[`{unit.Id}.{surface.Name}`] = true
			end

			Rivet.Use(plugin)
			startWithRoot(Fixtures.Surfaces.Units)

			expect(seen["Inventory.GetItems"]).to.equal(true)
			expect(seen["Inventory.EquipItem"]).to.equal(true)
			expect(seen["Inventory.ItemAdded"]).to.equal(true)
		end)

		it("calls plugin OnDestroy", function()
			local events: { string } = {}
			local plugin: Types.Plugin = {
				Id = "DestroyPlugin",
			}

			plugin.OnDestroy = function(_self: Types.Plugin)
				table.insert(events, "Plugin.Destroy")
			end

			Rivet.Use(plugin)
			startWithRoot(Fixtures.Ordered.Units)
			Rivet.Destroy()

			expect(events[1]).to.equal("Plugin.Destroy")
		end)
	end)

	describe("failures", function()
		it("wraps plugin hook failures with plugin id and hook name", function()
			local plugin: Types.Plugin = {
				Id = "FailingPlugin",
			}

			plugin.OnUnitLoaded = function(_self: Types.Plugin)
				error("hook exploded")
			end

			Rivet.Use(plugin)

			local success, message = pcall(function()
				startWithRoot(Fixtures.Ordered.Units)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "FailingPlugin")
			expectMessageContains(message, "OnUnitLoaded")
			expectMessageContains(message, "hook exploded")
		end)
	end)
end
