--!strict

type AnyFunction = (...any) -> ...any

declare class RBXScriptConnection
	Connected: boolean
	function Disconnect(self)
end

declare class RBXScriptSignal
	function Connect(self, callback: AnyFunction): RBXScriptConnection
end

declare class Instance
	Name: string
	Parent: Instance?
	function ClearAllChildren(self)
	function Destroy(self)
	function FindFirstChild(self, name: string): Instance?
	function GetChildren(self): { Instance }
	function GetDescendants(self): { Instance }
	function GetFullName(self): string
	function IsA(self, className: string): boolean
	function WaitForChild(self, name: string, timeout: number?): Instance?
end

declare class ModuleScript extends Instance
end

declare class Folder extends Instance
end

declare class Player extends Instance
end

declare class Players extends Instance
	function GetPlayers(self): { Player }
end

declare class RemoteEvent extends Instance
	OnClientEvent: RBXScriptSignal
	OnServerEvent: RBXScriptSignal
	function FireAllClients(self, ...: any)
	function FireClient(self, player: Player, ...: any)
	function FireServer(self, ...: any)
end

declare class RemoteFunction extends Instance
	OnServerInvoke: (player: Player, ...any) -> ...any
	function InvokeServer(self, ...: any): ...any
end

declare class RunService extends Instance
	function IsClient(self): boolean
	function IsServer(self): boolean
end

declare class StringValue extends Instance
	Value: string
end

declare class BindableEvent extends Instance
	Event: RBXScriptSignal
	function Fire(self, ...: any)
end

declare class ReplicatedStorage extends Instance
	Rivet: ModuleScript
	RivetRemotes: Folder?
	Tests: Folder
	DevPackages: Folder
	ExampleUnits: Folder
end

declare class ServerScriptService extends Instance
end

declare class DataModel
	function GetService(self, serviceName: "ReplicatedStorage"): ReplicatedStorage
	function GetService(self, serviceName: "ServerScriptService"): ServerScriptService
	function GetService(self, serviceName: "Players"): Players
	function GetService(self, serviceName: "RunService"): RunService
	function GetService(self, serviceName: string): Instance
end

declare game: DataModel
declare script: Instance

declare Instance: {
	new: ((className: "BindableEvent") -> BindableEvent)
		& ((className: "Folder") -> Folder)
		& ((className: "RemoteEvent") -> RemoteEvent)
		& ((className: "RemoteFunction") -> RemoteFunction)
		& ((className: "StringValue") -> StringValue)
		& ((className: string) -> Instance),
}

declare function require(moduleScript: ModuleScript): any
declare function typeof(value: any): string
declare function warn(...: any): ()

type TestExpectationTo = {
	equal: (expected: any) -> (),
}

type TestExpectation = {
	to: TestExpectationTo,
}

declare function beforeEach(callback: () -> ()): ()
declare function afterEach(callback: () -> ()): ()
declare function beforeAll(callback: () -> ()): ()
declare function afterAll(callback: () -> ()): ()
declare function describe(name: string, callback: () -> ()): ()
declare function it(name: string, callback: () -> ()): ()
declare function expect(value: any): TestExpectation
