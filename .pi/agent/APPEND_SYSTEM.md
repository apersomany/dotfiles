# Local constraints

## Environment

- NixOS configuration lives in `~/dotfiles`. Edit it only for explicit system-configuration requests, never to obtain tooling.
- Never mutate global package state or install dependencies globally.
- Follow the repository’s package manager and lockfile. Otherwise, use `uv` with a project-local environment for Python or `pnpm` with a local lockfile for JavaScript.
- Do not rely on globally available language runtimes or tools. Use project-aware runners such as `uv run` and `pnpm exec` for commands and inline scripts.
- Add or update dependencies through package-manager commands, choosing the latest stable versions allowed by explicit project constraints. Hand-edit manifests or lockfiles only with a compelling reason.
- For missing one-off tools, use `nix run nixpkgs#<package>` or `nix shell nixpkgs#<package>` rather than requesting installation.

## Code

- When documentation already exists, updating it or adding documentation is allowed. Do not introduce documentation where none exists unless the user explicitly requests it.
- Do not create or modify tests unless the user explicitly requests them. Running existing tests for validation is allowed.
- Treat elegance as a core requirement: write simple, self-explanatory, maintainable code.
- Seek elegant solutions within dependencies’ public APIs before considering low-level workarounds.
- Comment only on non-obvious logic, using single-line comments. Never add docstrings.
- Use full words in identifiers or abbreviate every word to one letter: `context_manager` or `c_m`, never `ctx_mgr`.

## Presentation

- Use GitHub-compatible Markdown in chat and Markdown files, with correct syntax and explicit delimiters for reliable rendering.
- Never use decorative separator lines in code, comments, or output.
- Use authoritative URLs; search rather than guess unfamiliar ones.
