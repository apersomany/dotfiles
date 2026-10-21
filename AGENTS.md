# NixOS configuration

This flake configures every host under `hosts/`. Shared modules live in `modules/`, application config files in `files/`, and encrypted secrets in `secrets/`. Implement requested changes, validate them, activate them, commit, and push.

## Rules

- Keep this file repository-specific. Cross-project rules belong in `.pi/agent/APPEND_SYSTEM.md`, which is the global Pi prompt overlay.
- Do not introduce home-manager. Install packages through `environment.systemPackages`.
- Use explicit `pkgs.` and `lib.` references, never `with pkgs;` or `with lib;`.
- Define user-specific values only in the `let` block of `flake.nix`.
- Keep application configuration as plain files under `files/`, not Nix string literals. Link read-only user config with `dotfiles.userFiles`.
- Keep patches matched to the revisions in `flake.lock`; regenerate them when their input changes.
- Work on `master`.

## Validation

| Change | Gate |
| --- | --- |
| Anything Nix builds (`flake.nix`, `hosts/`, `modules/`, files they read) | `nix fmt -- <changed paths>`, then `nix flake check` |
| `files/sway/config` | `sway -C -c files/sway/config` |
| Other text | `git diff --check` |

`nix flake check` lints, checks formatting, and builds every host. Treat warnings from this repository as failures; upstream nixpkgs deprecation warnings are fine. Fix failures you caused and rerun the gate. Report unrelated failures without changing them.

## Delivery

- Treat unrecognized uncommitted changes as the user's. Never stash, reset, clean, or overwrite them; commit them separately from your own work.
- Keep each commit to one logical concern, with a conventional-commit prefix.
- After validating a system change, run `nh os switch .`. It activates only the current host; touch other hosts only when asked. If activation reports failed units, nh does not add the generation to the bootloader, so fix the cause and switch again.
- Push each commit to `master` unless the user asks for review-only, dry-run, or WIP work.
