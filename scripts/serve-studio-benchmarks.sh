#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
aftman_rojo="${HOME}/.aftman/bin/rojo"

if [[ -x "${aftman_rojo}" ]]; then
	rojo_bin="${aftman_rojo}"
else
	rojo_bin="$(command -v rojo)"
fi

cd "${repo_root}"
exec "${rojo_bin}" serve benchmark.project.json
