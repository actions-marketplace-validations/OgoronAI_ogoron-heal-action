# Ogoron Heal Action

Run Ogoron heal workflows for generated tests or project tests on Linux runners.

Current scope:
- `ubuntu-*` runners only
- Linux release assets only

## Required environment

Provide secrets via workflow `env`, not action inputs.

- `OGORON_REPO_TOKEN`
- `OGORON_LLM_API_KEY` when BYOK access is required

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `ui` | no | `false` | Run `ogoron heal ui-tests`. |
| `unit-api` | no | `false` | Run `ogoron heal tests`. |
| `project` | no | `false` | Add `--project` to `ogoron heal tests`. |
| `working-directory` | no | `.` | Repository directory where commands should run. |
| `cli-version` | no | `5.2.0` | Ogoron CLI release version to download. Versions older than `5.2.0` are rejected. |
| `download-url` | no |  | Explicit Linux bundle URL override. |
| `debug` | no | `false` | Pass `--debug` to Ogoron heal commands. |

## Outputs

| Output | Description |
| --- | --- |
| `ogoron-bin` | Absolute path to the downloaded Ogoron executable. |

## Notes

- At least one of `ui`, `unit-api`, or `project` must be `true`.
- `project=true` changes the `heal tests` invocation to project mode and therefore takes precedence over plain generated-batch execution for that branch.
- `ui=true` can be combined with either generated or project heal-tests execution.
