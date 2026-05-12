--!strict
local Graph = {}

function Graph.Sort(registry)
	local units = registry:All()

	local sorted = {}
	local temporary = {}
	local permanent = {}

	local function visit(id, stack)
		if permanent[id] then
			return
		end

		if temporary[id] then
			error(`Circular Rivet dependency detected: {table.concat(stack, " -> ")} -> {id}`, 2)
		end

		local unit = units[id]

		if not unit then
			error(`Unknown Rivet unit dependency "{id}"`, 2)
		end

		temporary[id] = true
		table.insert(stack, id)

		for _, dependencyId in ipairs(unit.Dependencies or {}) do
			if not units[dependencyId] then
				error(`Unit "{id}" depends on missing unit "{dependencyId}"`, 2)
			end

			visit(dependencyId, stack)
		end

		table.remove(stack)
		temporary[id] = nil
		permanent[id] = true

		table.insert(sorted, id)
	end

	for id in pairs(units) do
		visit(id, {})
	end

	return sorted
end

return Graph