--!strict

--[=[
	@class InternalTypes
	@within Types

	Internal type boundary for dynamic Luau and Roblox runtime operations.

	Rivet keeps unavoidable `any` use here so the public runtime modules can stay
	explicitly typed while still supporting dynamic `require` results and cleanup
	method dispatch.
]=]

-- Types

export type DynamicValue = any
export type DynamicTable = { [any]: any }
export type DynamicFunction = (...any) -> ...any

return nil
