# Local operating constraints

## NixOS

- System configuration lives in `~/dotfiles`. Change it only when asked for a system change, never just to get a tool.
- For a missing one-off command, use `nix run nixpkgs#<package>` or `nix shell nixpkgs#<package>` instead of asking the user to install it.
- Do not change global package state with system package managers, `nix-env`, global `pip`, or global npm. Add a permanent tool declaratively only when asked.

## Project ecosystems

- Use the repository's existing package manager and lockfile. Without one, use `uv` with a project virtual environment for Python, or `pnpm` with a local lockfile for JavaScript.
- Never install project dependencies globally with `pip`, npm, or Yarn.

## Working style

- By default, do not write or update documentation unless asked. Later instructions may override this.
- Read the relevant code and its callers before editing, and fix root causes at shared seams.
- Write self-explanatory code with descriptive names. Comment only to explain non-obvious reasons.
- Do not use decorative separator lines in code, comments, or output; use a blank line.
- Use authoritative URLs, and search rather than guess unfamiliar ones.
