--!strict

--[=[
	@class StudioBenchmarkConfig

	Shared configuration for live Studio remote benchmarks.
]=]

-- Public API

local Config = {
	Iterations = 500,
	Warmups = 0,
	TimeoutSeconds = 5,
	PayloadSizes = {
		0,
		128,
		1_024,
		8_192,
	},
	ProgressRemoteName = "RivetStudioBenchmarkProgress",
	ProgressMarker = "RIVET_STUDIO_BENCHMARK_PROGRESS",
	ResultMarker = "RIVET_STUDIO_BENCHMARK_JSON:",
}

return Config
