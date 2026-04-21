#!/usr/bin/env bash
set -euo pipefail

debug_flag=()
if [[ "${INPUT_DEBUG:-false}" == "true" ]]; then
  debug_flag+=(--debug)
fi

selected=0
if [[ "${INPUT_UI:-false}" == "true" ]]; then
  selected=1
fi
if [[ "${INPUT_UNIT_API:-false}" == "true" ]]; then
  selected=1
fi
if [[ "${INPUT_PROJECT:-false}" == "true" ]]; then
  selected=1
fi

if [[ "${selected}" -ne 1 ]]; then
  echo "At least one of ui/unit-api/project must be true." >&2
  exit 2
fi

runtime_dir="$(dirname "${OGORON_BIN}")"
export PATH="${runtime_dir}:${PATH}"

if [[ "${INPUT_PROJECT:-false}" == "true" ]]; then
  ogoron heal tests --project "${debug_flag[@]}"
elif [[ "${INPUT_UNIT_API:-false}" == "true" ]]; then
  ogoron heal tests "${debug_flag[@]}"
fi

if [[ "${INPUT_UI:-false}" == "true" ]]; then
  ogoron heal ui-tests "${debug_flag[@]}"
fi
