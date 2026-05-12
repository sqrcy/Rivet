--!strict

local Loader = require(script.Loader)
local Registry = require(script.Registry)
local Graph = require(script.Graph)
local Runtime = require(script.Runtime)

local Rivet = {}

Rivet._runtime = nil
Rivet._registry = nil
Rivet._order = nil

function Rivet.Start(config)
	assert(type(config) == "table", "Rivet.Start expects a config table")
	assert(type(config.Roots) == "table", "Rivet.Start requires config.Roots")

	local registry = Registry.new()
	local units = Loader.LoadRoots(config.Roots)

	for _, unit in ipairs(units) do
		registry:Add(unit)
	end

	local runtime = Runtime.new(registry)

	for _, unit in pairs(registry:All()) do
		runtime:Prepare(unit)
	end

	local order = Graph.Sort(registry)

	runtime:Init(order)
	runtime:Start(order)

	Rivet._runtime = runtime
	Rivet._registry = registry
	Rivet._order = order

	return Rivet
end

function Rivet.Get(id)
	assert(Rivet._runtime, "Rivet has not started")
	return Rivet._runtime:Get(id)
end

function Rivet.Destroy()
	if Rivet._runtime and Rivet._order then
		Rivet._runtime:Destroy(Rivet._order)
	end

	Rivet._runtime = nil
	Rivet._registry = nil
	Rivet._order = nil
end

return Rivet
