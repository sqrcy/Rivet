#!/usr/bin/env python3
"""Render Rivet benchmark JSON into a Markdown report."""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any


def micros(seconds: float) -> float:
    return seconds * 1_000_000


def fmt_micro(seconds: float) -> str:
    return f"{micros(seconds):,.2f}"


def fmt_ops(value: float) -> str:
    if math.isinf(value) or math.isnan(value):
        return "0"
    return f"{value:,.0f}"


def render_table(scenarios: list[dict[str, Any]]) -> list[str]:
    lines = [
        "| Scenario | Category | Mean us/op | Median us/op | Min us/op | Max us/op | Std dev us | Ops/sec | Samples | Iterations |",
        "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]

    for scenario in scenarios:
        lines.append(
            "| {name} | {category} | {mean} | {median} | {min_} | {max_} | {stddev} | {ops} | {samples} | {iterations} |".format(
                name=scenario["Name"],
                category=scenario["Category"],
                mean=fmt_micro(scenario["MeanSeconds"]),
                median=fmt_micro(scenario["MedianSeconds"]),
                min_=fmt_micro(scenario["MinSeconds"]),
                max_=fmt_micro(scenario["MaxSeconds"]),
                stddev=fmt_micro(scenario["StdDevSeconds"]),
                ops=fmt_ops(scenario["OpsPerSecond"]),
                samples=len(scenario["Samples"]),
                iterations=scenario["Iterations"],
            )
        )

    return lines


def render_notes(scenarios: list[dict[str, Any]]) -> list[str]:
    lines = []

    for scenario in scenarios:
        lines.append(f"- **{scenario['Name']}**: {scenario['Notes']}")

    return lines


def render_network_stats(stats: dict[str, Any]) -> list[str]:
    lines = [
        "| Unit | Surface | Kind | Calls | Failures |",
        "| --- | --- | --- | ---: | ---: |",
    ]

    for unit_id in sorted(stats):
        unit_stats = stats[unit_id]

        for surface_name in sorted(unit_stats):
            surface_stats = unit_stats[surface_name]
            lines.append(
                f"| {unit_id} | {surface_name} | {surface_stats['Kind']} | {surface_stats['Calls']} | {surface_stats['Failures']} |"
            )

    return lines


def render_studio_placeholder() -> list[str]:
    return [
        "## Live Studio Remote Benchmarks",
        "",
        "Environment:",
        "",
        "- Roblox Studio version:",
        "- OS:",
        "- CPU:",
        "- Client count:",
        "- Iterations:",
        "- Warmup iterations:",
        "- Payload:",
        "- Runner: Rojo-served Studio play session",
        "",
        "| Benchmark | Payload bytes | Mean ms | Median ms | P95 ms | P99 ms | Min ms | Max ms | Drops | Notes |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
        "| Native RemoteFunction | | | | | | | | | |",
        "| Rivet Query | | | | | | | | | |",
        "| Native RemoteEvent echo | | | | | | | | | |",
        "| Rivet Action echo | | | | | | | | | |",
        "| Rivet Signal fanout | | | | | | | | | |",
        "",
    ]


def read_existing_studio_section(output_path: Path) -> list[str] | None:
    if not output_path.exists():
        return None

    text = output_path.read_text(encoding="utf-8")
    marker = "## Live Studio Remote Benchmarks"
    start = text.find(marker)

    if start == -1:
        return None

    section = text[start:]
    previous = section.find("\nPrevious:")

    if previous != -1:
        section = section[:previous]

    return section.rstrip().splitlines() + [""]


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: render-benchmark-report.py <input.json> <output.md>", file=sys.stderr)
        return 2

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    report = json.loads(input_path.read_text(encoding="utf-8"))
    scenarios = report["Scenarios"]
    studio_section = read_existing_studio_section(output_path) or render_studio_placeholder()

    lines = [
        "# Benchmark Results",
        "",
        "These results use the benchmark categories described in [Benchmarks](benchmarks.md).",
        "",
        "## What The Benchmarks Are",
        "",
        "Engine/headless benchmarks measure Rivet runtime overhead in a Roblox",
        "DataModel. Studio remote benchmarks measure live client/server remote",
        "behavior in a local Studio play session.",
        "",
        "### Engine/Headless Benchmarks",
        "",
        *render_notes(scenarios),
        "",
        "### Studio Remote Benchmarks",
        "",
        "- **Native RemoteFunction**: native request/response baseline.",
        "- **Rivet Query**: Rivet Query proxy over RemoteFunction.",
        "- **Native RemoteEvent echo**: native event round trip with server echo.",
        "- **Rivet Action echo**: Rivet Action request echoed through a Rivet Signal.",
        "- **Rivet Signal fanout**: server FireAll signal delivery to the benchmark client.",
        "",
        "## Engine/Headless Results",
        "",
        *render_table(scenarios),
        "",
        "## Network Debug Counters",
        "",
        *render_network_stats(report["NetworkStats"]),
        "",
        "## Reading The Numbers",
        "",
        "The benchmark reports microseconds per operation. Lower mean and median values are better. The standard deviation column shows how much samples moved around during the run.",
        "",
        "Use the numbers as a comparison point between Rivet changes. The most useful signal is how a scenario moves relative to its previous result.",
        "",
        "For live Studio remote results, compare P50, P95, P99, and drops together. Remote behavior can look healthy on average while still showing high-percentile spikes or throttled requests.",
        "",
        *studio_section,
        "Previous: [Benchmarks](benchmarks.md)",
        "",
    ]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {output_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
