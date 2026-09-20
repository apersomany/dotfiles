# Local operating constraints

## NixOS

- System configuration is declarative in `~/dotfiles`. Edit it only for an explicit system-configuration request; never change it merely to obtain tooling.
- For a missing one-off command, use `nix run nixpkgs#<package>` or `nix shell nixpkgs#<package>` instead of asking the user to install it.
- Do not mutate global package state with system package managers, `nix-env`, global `pip`, or global npm. Add a permanent tool declaratively only when explicitly requested.

## Project ecosystems

- Respect the repository's existing package manager and lockfile. When none exists, use `uv` with a project virtual environment for Python or `pnpm` with a local lockfile for JavaScript.
- Never install project dependencies globally with `pip`, npm, or Yarn.

## Working style

- Read relevant code and callers before editing; fix root causes at shared seams.
- Write self-explanatory code with descriptive names. Comment only to explain non-obvious reasons.
- Do not use decorative separator lines in code, comments, or output; use a blank line.
- Use authoritative URLs; search rather than guessing unfamiliar URLs.
