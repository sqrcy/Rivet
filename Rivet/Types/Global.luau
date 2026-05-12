--!strict

export type Unit = {
    Id: string?,
    Dependencies: { string }?,

    Init: ((self: UnitContext) -> ())?,
    Start: ((self: UnitContext) -> ())?,
    Destroy: ((self: UnitContext) -> ())?,
}

export type UnitContext = Unit & {
    Id: string,
    Cleaner: any,
    Get: (self: UnitContext, id: string) -> UnitContext,
}

export type Config = {
    Roots: { Instance },
}

export type Registry = {
    [string]: UnitContext,
}

return {}