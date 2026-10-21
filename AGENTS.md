# NixOS workstation configuration

This flake configures every host under `hosts/` (currently `workstation` and `scg-workstation`); shared configuration lives in `modules/`. Implement requested changes, validate them, activate system changes, commit, and push directly.

## Boundaries

- Keep `AGENTS.md` repository-specific. `.pi/agent/APPEND_SYSTEM.md` is exposed as the global Pi prompt overlay at `~/.pi/agent/APPEND_SYSTEM.md`; keep only cross-project rules there.
- Do not introduce home-manager. Install packages through `environment.systemPackages`.
- Use explicit `pkgs.` and `lib.` references; never use `with pkgs;` or `with lib;`.
- Define user-specific values only in the `flake.nix` `let` block.
- Keep application configuration as plain files under `files/`, not Nix string literals. Link read-only user configuration with `dotfiles.userFiles`.
- Keep patches aligned with the revisions pinned in `flake.lock`; regenerate them when their input changes.
- Work on `master`.

## Validation

Run only the gates applicable to changed files:

| Change | Commands |
| --- | --- |
| Nix (`flake.nix`, `hosts/`, `modules/`) | `nix fmt -- <changed Nix paths>`, then `nix flake check` (lint, formatting, and every host build) |
| Sway (`files/sway/config`) | `sway -C -c files/sway/config` |
| Documentation or other text | `git diff --check` |

Treat lint warnings and warnings from this repository during `nix flake check` as failures. Upstream nixpkgs deprecation warnings are acceptable. Fix task-caused failures at the source and rerun the failed gate; report unrelated failures without modifying them.

## Delivery

- Preserve unrelated work. Never stash, reset, clean, overwrite, stage, or commit changes outside the current task.
- Assume unrecognized uncommitted changes were made by the user and commit them as part of delivery.
- Keep each commit to one logical concern and use a conventional-commit prefix.
- After validation, run `nh os switch .` for system configuration changes. It activates only the host it runs on; activate other hosts only when the user asks. Do not activate unrelated uncommitted Nix changes without user approval.
- Push each successful commit to `master` unless the user explicitly requests review-only, dry-run, or WIP work.
