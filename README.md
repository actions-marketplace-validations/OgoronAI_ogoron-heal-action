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
| `create-pr` | no | `false` | Create or update a pull request when healing changes repository files. |
| `pr-branch` | no | `ogoron/heal` | Branch used for healed artifact changes. |
| `pr-title` | no | `Heal Ogoron test artifacts` | Pull request title. |
| `commit-message` | no | `Heal Ogoron test artifacts` | Commit message used for healed artifacts. |
| `author-name` | no | `ogoron-bot` | Git author name for the healed commit. |
| `author-email` | no | `agents@ogoron.com` | Git author email for the healed commit. |

## Outputs

| Output | Description |
| --- | --- |
| `ogoron-bin` | Absolute path to the downloaded Ogoron executable. |
| `changes-detected` | Whether healing changed repository files. |
| `pull-request-url` | URL of the created or updated pull request, if any. |
| `branch-name` | Branch name used for healed artifacts. |

## Notes

- At least one of `ui`, `unit-api`, or `project` must be `true`.
- `project=true` changes the `heal tests` invocation to project mode and therefore takes precedence over plain generated-batch execution for that branch.
- `ui=true` can be combined with either generated or project heal-tests execution.
- When `create-pr=true`, the action commits healed changes locally and then opens or updates a pull request through `peter-evans/create-pull-request`.

## Related actions

- [`Ogoron Setup`](https://github.com/OgoronAI/ogoron-setup-action) to bootstrap the repository before CI usage
- [`Ogoron Generate`](https://github.com/OgoronAI/ogoron-generate-action) to create test artifacts that may later need healing
- [`Ogoron Run`](https://github.com/OgoronAI/ogoron-run-action) to execute tests and surface failures before healing
- [`Ogoron Exec`](https://github.com/OgoronAI/ogoron-exec-action) for custom remediation flows

## Recommended flow

1. Use `run` to surface failing generated or project tests.
2. Run `heal` only after you understand the failing scope.
3. Use `create-pr=true` when healed artifacts should be delivered back into the repository automatically.
