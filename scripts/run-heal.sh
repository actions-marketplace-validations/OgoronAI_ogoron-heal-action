#!/usr/bin/env bash
set -euo pipefail

git config user.name "${INPUT_AUTHOR_NAME:-ogoron-bot}"
git config user.email "${INPUT_AUTHOR_EMAIL:-agents@ogoron.com}"

commit_if_changes() {
  local message="$1"
  if [[ -z "$(git status --porcelain)" ]]; then
    return 1
  fi

  git add -A
  git commit -m "${message}" >/dev/null
  return 0
}

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

changes_detected="false"
if commit_if_changes "Heal Ogoron test artifacts"; then
  changes_detected="true"
elif [[ -n "$(git status --porcelain)" ]]; then
  changes_detected="true"
fi

pr_body_path="${RUNNER_TEMP:-/tmp}/ogoron-heal-pr-body.md"
cat > "${pr_body_path}" <<EOF
## What Ogoron healed

This PR contains repository changes produced by the \`heal\` action.

## Requested heal scope

- ui: \`${INPUT_UI:-false}\`
- unit-api: \`${INPUT_UNIT_API:-false}\`
- project: \`${INPUT_PROJECT:-false}\`

## Commands used

$(if [[ "${INPUT_PROJECT:-false}" == "true" ]]; then echo "- \`ogoron heal tests --project\`"; fi)
$(if [[ "${INPUT_PROJECT:-false}" != "true" && "${INPUT_UNIT_API:-false}" == "true" ]]; then echo "- \`ogoron heal tests\`"; fi)
$(if [[ "${INPUT_UI:-false}" == "true" ]]; then echo "- \`ogoron heal ui-tests\`"; fi)

## Review notes

- Review healed files before merge.
- If the action changed unexpected files, rerun with a narrower scope.
- Keep healing PRs small and easy to reason about.
EOF

{
  echo "changes-detected=${changes_detected}"
  echo "pr-body-path=${pr_body_path}"
} >> "${GITHUB_OUTPUT}"
