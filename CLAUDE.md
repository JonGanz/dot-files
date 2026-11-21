# CLAUDE.md

Repo for reproducible Linux machine setup (Kubuntu, Arch, NixOS, WSL2 Ubuntu). Public-safe: nothing secret or work-specific is ever committed.

## Design decisions (settled, don't relitigate)

- **Packages (CLI):** Nix flake, used on every distro. No home-manager on non-NixOS.
- **GUI apps:** native package manager (apt/pacman/flatpak) on Kubuntu/Arch; Nix on NixOS. Lists live in `native/`.
- **Dotfiles:** plain files in `dotfiles/`, installed as symlinks into the repo by a bash linker, so edits are live and drift shows in `git diff`. Never generate dotfiles from Nix.
- **Linker:** `scripts/link.sh`. Keeps a state file (`~/.local/state/setup/links`) of links it made; removes only stale links that still point into the repo/overlay. Never overwrites or deletes real files; supports `--dry-run`, `--adopt`, `--backup`.
- **`~/.claude/skills` (and commands, output-styles) are real directories** containing one symlink per item, sourced from both this repo and the private overlay. New items Claude creates there are real, unmanaged entries until adopted.
- **`setup adopt <path> --to base|overlay`** moves one item into the chosen repo and links it back. Each item chooses its destination independently (e.g. one new skill to base, another to overlay in the same session). `setup status` lists unmanaged items; a shell-prompt nudge flags them.
- **Profiles:** shared base + `personal` / `work` overlays selected per machine.
- **Private overlay:** an optional, independent private repo (NOT a submodule) cloned to a path from untracked local machine config (default `~/.config/setup-private`). Holds work dotfiles, work Claude config, work SSH keys. This repo never records its name or URL; it only has the hook that links the overlay in if the path exists.
- **Secrets:** never in this repo, encrypted or not. Bitwarden CLI at runtime where needed. SSH: bootstrap generates an ed25519 key if missing, interactively, always with a passphrase (never empty); work keys live in the private overlay. Gitleaks runs as a local pre-commit hook (no CI).
- **Cruft report:** native Linux only, opt-in kernel-level exec auditing (auditd/bpftrace) joined with the installed-package list. Skipped on WSL.
- **WSL:** CLI tooling only, via Nix with systemd enabled.

## Layout

- `flake.nix`: entry point; bundles from `packages.nix`, and a NixOS host for every `machines/<dir>` (dirs starting `_` ignored)
- `packages.nix`: single source of truth for all package lists (also used by `nixos/`)
- `nixos/`: NixOS module shared by hosts (`setup.profile`, `setup.desktop` options)
- `dotfiles/`: bash, git (with `includeIf` for `~/work/`), nvim, wezterm, tmux, taskwarrior, `bin/` scripts
- `claude/`: skills, commands, output-styles, settings
- `native/`: apt / pacman / flatpak lists
- `scripts/`: bootstrap, link, status, adopt, cruft report
- `links.map`: what gets linked where (modes `link` and `children`); read by `link`, `status`, `adopt`
- `machines/`: one dir per NixOS host (the installer's configuration.nix + hardware-configuration.nix + `setup.*` settings; start from `_template/`) (profile and overlay path live in untracked `~/.config/setup/local.env`)

## Conventions

- Scripts are bash with `set -euo pipefail`, shellcheck-clean, and comment nearly everything: file header explaining purpose and usage, a comment on every function and non-obvious line. Optimize for readability over cleverness.
- No external dependencies beyond bash, coreutils, git, and Nix.
- Every script that changes the system supports `--dry-run`.
- README stays short: structure, per-target setup steps (mostly commands), shared usage. No filler.
- Never add features or files beyond what's asked. Commit freely with clean messages: no Co-Authored-By trailer or other attribution lines. Never touch `~/setup` (the user's existing directory) and never actually install anything while testing; test scripts only with `--dry-run` or a throwaway `HOME` under the scratchpad, against a copy of the repo.
- `claude/` contains only generic, shareable content. Anything work-specific belongs in the private overlay.
