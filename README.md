# home-assistant-config

Hand-written Home Assistant config for `ha.amer.dev`. Merged to `main` = live within about a minute.

## How it reaches HA

- A git-sync sidecar in the HA pod checks this repo out at `/config/git/current` every 30 s
  (deployed by `dean-amer-dev/dean-tofu` `k3s/apps/prod/home-assistant`).
- After each new commit it calls a local HA webhook; an automation in `packages/` reloads HA.
- On every pod start an init container copies `configuration.yaml` from here to `/config/configuration.yaml`
  and links `/config/python_scripts` and `/config/blueprints` here.

## Layout

| Path | What |
|---|---|
| `configuration.yaml` | Top-level keys that cannot live in a package. **Changes need an HA restart.** |
| `packages/*.yaml` | Everything else, one file per area. Includes are relative to the package file (`../scripts`). |
| `automations/`, `scripts/`, `helpers/<domain>/` | YAML automations, scripts and helpers, pulled in by `packages/core.yaml`. |
| `dashboards/views/` | YAML dashboards, registered in `configuration.yaml` (a new dashboard needs a restart; edits do not). |
| `python_scripts/`, `blueprints/`, `themes/`, `scripts_shell/` | As named. |
| `ci/check.sh` | Builds a throwaway `/config` shaped like the pod and runs `check_config`. |

## Not in git (stays on the HA PVC)

UI-created automations/scenes/scripts (`automations.yaml`, `scenes.yaml`, `scripts.yaml`), `.storage`
(integrations, entity registry, UI dashboards), `custom_components` and `www` (installed by the init container).

## Needs a restart

New integrations or top-level keys, `configuration.yaml` edits, registering a new dashboard,
custom component bumps (dean-tofu).

## Check locally

    docker run --rm --entrypoint "" -v "$PWD:/repo:ro" ghcr.io/home-assistant/home-assistant:2026.7.0 sh /repo/ci/check.sh

Keep the image tag in `.github/workflows/check.yaml` equal to the live HA version. Roll back = revert the PR.
