--!strict

--[=[
	@class CleanSpec

	Tests for Rivet's built-in cleanup utility.
]=]

-- Constants

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rivet = require(ReplicatedStorage.Rivet)
local Internal = require(ReplicatedStorage.Rivet.Types.Internal)
local Clean = Rivet.Clean

-- Private helpers

local function expectMessageContains(message: unknown, expected: string)
	expect(tostring(message):find(expected, 1, true) ~= nil).to.equal(true)
end

-- Tests

return function()
	describe("Clean", function()
		it("adds and cleans function tasks in reverse order", function()
			local clean = Clean.new()
			local events: { string } = {}

			clean:Add(function()
				table.insert(events, "first")
			end)

			clean:Add(function()
				table.insert(events, "second")
			end)

			clean:Cleanup()

			expect(events[1]).to.equal("second")
			expect(events[2]).to.equal("first")
		end)

		it("removes tasks without cleaning them", function()
			local clean = Clean.new()
			local called = false

			local task = clean:Add(function()
				called = true
			end)

			expect(clean:Remove(task)).to.equal(true)
			clean:Cleanup()

			expect(called).to.equal(false)
		end)

		it("cleans Roblox Instances", function()
			local clean = Clean.new()
			local folder = Instance.new("Folder")
			folder.Parent = ReplicatedStorage

			clean:Add(folder)
			clean:Cleanup()

			expect(folder.Parent).to.equal(nil)
		end)

		it("cleans RBXScriptConnections", function()
			local clean = Clean.new()
			local bindable = Instance.new("BindableEvent")
			local fired = false

			local connection = bindable.Event:Connect(function()
				fired = true
			end)

			clean:Add(connection)
			clean:Cleanup()
			bindable:Fire()
			bindable:Destroy()

			expect(fired).to.equal(false)
		end)

		it("cleans table Destroy, Disconnect, and Cleanup methods", function()
			local clean = Clean.new()
			local events: { string } = {}

			clean:Add({
				Destroy = function()
					table.insert(events, "Destroy")
				end,
			})

			clean:Add({
				Disconnect = function()
					table.insert(events, "Disconnect")
				end,
			})

			clean:Add({
				Cleanup = function()
					table.insert(events, "Cleanup")
				end,
			})

			clean:Cleanup()

			expect(events[1]).to.equal("Cleanup")
			expect(events[2]).to.equal("Disconnect")
			expect(events[3]).to.equal("Destroy")
		end)

		it("uses explicit method overrides", function()
			local clean = Clean.new()
			local called = false

			clean:Add({
				Finish = function()
					called = true
				end,
			}, "Finish")

			clean:Cleanup()

			expect(called).to.equal(true)
		end)

		it("aliases Destroy to Cleanup", function()
			local clean = Clean.new()
			local called = false

			clean:Add(function()
				called = true
			end)

			clean:Destroy()

			expect(called).to.equal(true)
		end)

		it("errors clearly for nil tasks", function()
			local clean = Clean.new()
			local success, message = pcall(function()
				local cleanDynamic = clean :: Internal.DynamicTable
				(cleanDynamic.Add :: Internal.DynamicFunction)(clean, nil)
			end)

			expect(success).to.equal(false)
			expectMessageContains(message, "cannot add nil")
		end)
	end)
end
