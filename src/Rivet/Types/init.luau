--!strict

--[=[
	@class Types

	Public and shared internal type definitions for Rivet.
]=]

-- Types

export type CleanupMethodName = string

export type Clean = {
	Add: <T>(self: Clean, object: T, methodName: CleanupMethodName?) -> T,
	Remove: (self: Clean, object: unknown) -> boolean,
	Cleanup: (self: Clean) -> (),
	Destroy: (self: Clean) -> (),
}

export type CleanConstructor = {
	new: () -> Clean,
}

export type CodecDefinition = {
	Encode: (value: unknown) -> unknown,
	Decode: (data: unknown) -> unknown,
}

export type CodecRegistry = {
	Register: (self: CodecRegistry, id: string, codec: CodecDefinition) -> (),
}

export type Plugin = {
	Id: string,

	Init: ((self: Plugin, rivet: Rivet) -> ())?,
	Start: ((self: Plugin, rivet: Rivet) -> ())?,
	OnUnitLoaded: ((self: Plugin, unit: UnitContext) -> ())?,
	OnUnitPrepared: ((self: Plugin, unit: UnitContext) -> ())?,
	OnUnitInit: ((self: Plugin, unit: UnitContext) -> ())?,
	OnUnitStart: ((self: Plugin, unit: UnitContext) -> ())?,
	OnSurfaceRegistered: ((self: Plugin, unit: UnitContext, surface: SurfaceRecord) -> ())?,
	OnNetworkCall: ((self: Plugin, context: unknown) -> ())?,
	OnNetworkError: ((self: Plugin, context: unknown) -> ())?,
	OnDestroy: ((self: Plugin) -> ())?,

	[string]: unknown,
}

export type SurfaceKind = "Query" | "Action" | "Signal"

export type SurfaceScope = "Client" | "Shared"

export type SurfaceDefinition = {
	Kind: SurfaceKind,
	Args: { string }?,
	Returns: string?,
	Payload: { string }?,
}

export type SurfaceRecord = {
	Name: string,
	Kind: SurfaceKind,
	Scope: SurfaceScope,
	Args: { string }?,
	Returns: string?,
	Payload: { string }?,
}

export type NormalizedSurfaces = {
	Client: { [string]: SurfaceRecord },
	Shared: { [string]: SurfaceRecord },
}

export type UnitContext = {
	Id: string,
	Dependencies: { string },
	Surfaces: NormalizedSurfaces,
	Clean: Clean,
	Client: { [string]: unknown }?,
	Get: (self: UnitContext, id: string) -> UnitContext,

	Init: ((self: UnitContext) -> ())?,
	Start: ((self: UnitContext) -> ())?,
	Destroy: ((self: UnitContext) -> ())?,

	[string]: unknown,
}

export type UnitDefinition = {
	Id: string?,
	Dependencies: { string }?,
	Surfaces: unknown?,

	Init: ((self: UnitContext) -> ())?,
	Start: ((self: UnitContext) -> ())?,
	Destroy: ((self: UnitContext) -> ())?,

	[string]: unknown,
}

export type UnitRecord = {
	Id: string,
	Dependencies: { string },
	Surfaces: NormalizedSurfaces,
	Module: ModuleScript,
	SourcePath: string,
	Unit: UnitContext,
}

export type DebugConfig = {
	Network: boolean?,
}

export type StartConfig = {
	Roots: { Instance },
	Debug: DebugConfig?,
}

export type ValueTuple = {
	[number]: unknown,
	n: number,
}

export type NetworkSurfaceStats = {
	Kind: SurfaceKind,
	Calls: number,
	Failures: number,
}

export type NetworkStats = {
	[string]: {
		[string]: NetworkSurfaceStats,
	},
}

export type Debug = {
	GetNetworkStats: (self: Debug) -> NetworkStats,
}

export type Registry = {
	Add: (self: Registry, record: UnitRecord) -> (),
	Get: (self: Registry, id: string) -> UnitRecord,
	Has: (self: Registry, id: string) -> boolean,
	All: (self: Registry) -> { [string]: UnitRecord },
	Order: (self: Registry) -> { string },
}

export type Runtime = {
	Prepare: (self: Runtime, record: UnitRecord) -> (),
	AddProxy: (self: Runtime, id: string, proxy: UnitContext) -> (),
	Get: (self: Runtime, id: string) -> UnitContext,
	Init: (self: Runtime, order: { string }, onUnitInit: ((record: UnitRecord) -> ())?) -> (),
	Start: (self: Runtime, order: { string }, onUnitStart: ((record: UnitRecord) -> ())?) -> (),
	Destroy: (self: Runtime, order: { string }) -> (),
}

export type Rivet = {
	Clean: CleanConstructor,
	Codec: CodecRegistry,
	Debug: Debug,
	Use: (plugin: Plugin) -> Rivet,
	Start: (config: StartConfig) -> Rivet,
	Get: (selfOrId: Rivet | string, id: string?) -> UnitContext,
	Destroy: () -> (),
}

return nil
