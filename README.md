# setup

Reproducible Linux machine setup: Nix for CLI packages, native package managers for GUI apps, dotfiles symlinked live from this repo.

## Structure

```
setup            entry point (dispatches to scripts/)
flake.nix        Nix package sets: base, personal, work (+ NixOS modules)
dotfiles/        plain files, symlinked into $HOME
claude/          generic skills, commands, output-styles, settings -> ~/.claude
native/          apt / pacman / flatpak package lists (GUI apps, system packages)
machines/        NixOS host configs
scripts/         bootstrap, link, status, adopt, cruft
```

Machine-local state (never committed) lives in `~/.config/setup/local.env`:

```
PROFILE=personal            # or: work
OVERLAY=~/.config/setup-private   # optional private repo, layered over this one
```

Each repo has a `links.map` listing what gets linked where. `link` and `adopt` both read it:

```
# mode      repo path                 target
link        dotfiles/.bashrc          ~/.bashrc
link        dotfiles/.config/nvim     ~/.config/nvim
children    claude/skills             ~/.claude/skills
children    claude/commands           ~/.claude/commands
```

- `link`: link exactly this path (file or directory).
- `children`: link each child of the repo folder into the target folder.

`adopt` picks the repo path like this:

1. The item sits inside a `children` target: it goes into that rule's repo folder (`~/.claude/skills/foo` -> `claude/skills/foo`). No new line needed.
2. Otherwise it goes to `dotfiles/` plus its path relative to `$HOME` (`~/.config/wezterm` -> `dotfiles/.config/wezterm`), and a `link` line is appended.
3. Items outside `$HOME` need `--as <repo-path>`.

`--as <repo-path>` always skips the guessing, e.g. `adopt ~/.claude/settings.json --to base --as claude/settings.json`. A guessed destination is confirmed first (or pass `--yes`).

The overlay is a separate private repo with the same layout (`dotfiles/`, `claude/`, `links.map`, ...). It holds anything work-specific, including work SSH keys. This repo never references it.

## Ubuntu / Kubuntu

```sh
sudo apt update && sudo apt install -y git curl
git clone <repo-url> ~/setup && cd ~/setup
./setup bootstrap --profile personal
```

Bootstrap is idempotent. It installs Nix, apt packages and flatpaks from `native/`, the Nix package set for the profile, generates an SSH key if missing (asks for a passphrase), installs the gitleaks pre-commit hook, then links dotfiles.

## Arch

```sh
sudo pacman -S --needed git curl
git clone <repo-url> ~/setup && cd ~/setup
./setup bootstrap --profile personal
```

Same as Ubuntu, using `native/pacman*.txt`. Package lists: `apt.txt`/`pacman.txt` always, `*-gui.txt` and `flatpak.txt` on GUI machines. The overlay can add its own `native/` lists.

## NixOS

```sh
git clone <repo-url> ~/setup && cd ~/setup
sudo nixos-rebuild switch --flake .#<host>
./setup link
```

Packages come from the NixOS config in `machines/<host>`, so no bootstrap. `link` still handles dotfiles, so they stay live-editable.

## WSL2 (Ubuntu)

From Windows, enable systemd, then restart WSL:

```
# /etc/wsl.conf (inside WSL)
[boot]
systemd=true
```
```powershell
wsl --shutdown
```

Inside WSL:

```sh
sudo apt update && sudo apt install -y git curl
git clone <repo-url> ~/setup && cd ~/setup
git clone <private-overlay-url> ~/.config/setup-private   # work only
./setup bootstrap --profile work --cli-only
```

`--cli-only` skips GUI apps (WSL implies it). Kernel auditing for `cruft` isn't available on WSL.

## Usage

```sh
./setup link [--dry-run]            # create links; remove stale ones; never overwrites real files
./setup status                      # unmanaged files where links should be, plus repo drift
./setup adopt <path> --to base|overlay [--as <repo-path>]   # move an on-disk file/dir into a repo and link it back
./setup update                      # flake update + upgrade Nix and native packages, then link
./setup cruft [enable|report]       # kernel exec auditing and unused-package report (native Linux only)
```

- Edit anything under `dotfiles/` or `claude/` through its link; changes are live and show in `git diff`.
- A new skill or config created in place (e.g. by Claude) is unmanaged until adopted. `status` lists them, and the shell prompt shows a marker when any exist. Each item can go to a different repo: `adopt ~/.claude/skills/foo --to base`, `adopt ~/.claude/skills/bar --to overlay`.
- If a real file blocks a link, `link` skips it and says so. Resolve with `adopt` (keep it) or `link --backup` (move it aside).
- Work-only instructions for Claude go in `~/work/CLAUDE.md`, which Claude loads for every repo beneath it.
