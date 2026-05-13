--!strict

--[=[
	@class Graph

	Dependency graph sorting for Rivet units.
]=]

-- Types

local Types = require(script.Parent.Types)

-- Private helpers

local function formatCycle(id: string, stack: { string }): string
	local cycle: { string } = {}
	local foundStart = false

	for _, stackedId in ipairs(stack) do
		if stackedId == id then
			foundStart = true
		end

		if foundStart then
			table.insert(cycle, stackedId)
		end
	end

	table.insert(cycle, id)

	return table.concat(cycle, " -> ")
end

-- Public API

local Graph = {}

--[=[
	@param registry Registry
	@return {string}

	Sorts unit ids so dependencies appear before dependents.
]=]
function Graph.Sort(registry: Types.Registry): { string }
	local sorted: { string } = {}
	local temporary: { [string]: boolean } = {}
	local permanent: { [string]: boolean } = {}

	local function visit(id: string, stack: { string })
		if permanent[id] then
			return
		end

		if temporary[id] then
			error(
				`Rivet circular dependency. Circular Rivet dependency detected: {formatCycle(
					id,
					stack
				)}`,
				2
			)
		end

		local record = registry:Get(id)

		temporary[id] = true
		table.insert(stack, id)

		for _, dependencyId in ipairs(record.Dependencies) do
			if not registry:Has(dependencyId) then
				error(
					`Rivet missing dependency. Unit "{id}" depends on missing unit "{dependencyId}". Add a Unit with Id "{dependencyId}" under config.Roots or remove it from Dependencies.`,
					2
				)
			end

			visit(dependencyId, stack)
		end

		table.remove(stack)
		temporary[id] = nil
		permanent[id] = true

		table.insert(sorted, id)
	end

	for _, id in ipairs(registry:Order()) do
		visit(id, {})
	end

	return sorted
end

return Graph
