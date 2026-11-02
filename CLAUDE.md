# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A modular, idempotent Bash setup system for Linux (Arch, Ubuntu/Kubuntu, WSL2). It installs and configures a developer environment via intent-driven module profiles.

## Running the Setup

```bash
# Full setup with an intent
./setup.sh --intent personal
./setup.sh --intent work

# Run a single module
./setup.sh --only core/neovim
./setup.sh --only sdks/go --update

# Preview without executing
./setup.sh --intent personal --dry-run

# Force re-prompt for configuration values
./setup.sh --reconfigure

# Stop at the first failing module (default: continue and report)
./setup.sh --intent personal --fail-fast
```

There is no test suite. Validation is done by running with `--dry-run` first or targeting a single module.

Every run ends with a per-module summary (`ok` / `FAILED`) and exits non-zero if any module failed. A module fails when its subshell exits non-zero, i.e. when `install`, `configure` or `update` returns non-zero, so make sure a function's last command is not a benign `[ ... ] && ...` that returns 1.

## Architecture

### Execution Flow

`setup.sh` sources all `lib/` files, parses args, then calls `run_module()` for each entry in the active intent file(s). Each module runs in a subshell with all libs re-sourced, so state cannot leak between modules.

Intent files (`intents/common.txt`, `intents/personal.txt`, `intents/work.txt`) are plain text lists of module paths. `common` always runs; the selected intent's file is appended. Duplicates are deduplicated while preserving order.

### Module Contract

Every module lives at `modules/{category}/{name}/script.sh` and must define:

```bash
install()    # Required — package installation
configure()  # Required — symlinking configs, writing to .bashrc, etc.
update()     # Optional — if absent, install is called on --update
```

`configure()` always runs after `install()` or `update()`, including on `--update`, so config changes are applied on every run. Do not call `configure` from `install` or `update`. On Arch, `--update` runs one full `pacman -Syu` up front and per-package `pkg_update` is a safe `pacman -S --needed`.

Modules are sourced (not executed), so functions share the lib namespace. Use the `is_wsl`, `is_arch`, `is_ubuntu` helpers from `lib/env.sh` to branch platform-specific logic. Always guard GUI apps with `is_wsl` early-return.

### Shared Libraries

| File | Purpose |
|---|---|
| `lib/env.sh` | `is_arch()`, `is_ubuntu()`, `is_wsl()`, `detect_env()`, `get_arch(uname|go|native)` |
| `lib/log.sh` | `log_info/warn/error/success/step` — colored output |
| `lib/pkg.sh` | `pkg_install`, `pkg_update`, `flatpak_install`, `has_cmd`, `has_pkg`, `download_file`, `install_github_release` |
| `lib/util.sh` | `symlink_file`, `render_template`, `refresh_envs` |
| `lib/config.sh` | `load_config`, `save_config`, `ensure_config`, `reconfigure` |

### Installing Release Binaries

On Ubuntu, tools that are not in apt are installed from GitHub releases with `install_github_release <name> <version> <url_template> [path_in_archive] [version_cmd]`. The URL template may use `{version}`, `{arch}` (x86_64/arm64), `{arch_go}` (amd64/arm64) and `{arch_native}` (x86_64/aarch64). It handles `.tar.gz`, `.zip` and bare binaries, skips when the installed version already matches, and returns non-zero on any failure. Set `RELEASE_BIN_DIR` to install somewhere other than `/usr/local/bin`.

### Configuration System

User-specific values (git name/email, work directory) are stored in `.local.env` (gitignored). The `CONFIG_ITEMS` array in `lib/config.sh` defines what gets prompted. Config values are exported as shell variables and available inside modules after `load_config` runs.

`CONFIG_ITEMS` entries are `KEY|DESCRIPTION|DEFAULT|INTENTS`. The optional `INTENTS` field (comma-separated, empty = all) limits upfront prompting to those intents. Any code that parses an item with `IFS='|' read` must name all four fields. A module that needs a value regardless of intent (e.g. when run with `--only`) declares `CONFIG_REQUIRES=(key ...)`; `run_module` calls `ensure_module_config` to prompt for any that are unset, and fails the module if there's no TTY to ask on.

Config templates use `{{ variable_name }}` placeholders. `render_template src dest` replaces these with values from `CONFIG_ITEMS` variables.

`refresh_envs` sources `modules/sdks/*/env.sh` to make SDK tools (cargo, nvm, go) available within the current subshell — call this before using a tool installed by a prior module.

### SDK Environment Files

Each SDK module that modifies PATH has a companion `modules/sdks/{name}/env.sh` that sets up the environment for that SDK. These are sourced by `refresh_envs` so later modules can use tools from earlier SDK installs within the same run.

### Adding a Module

1. Create `modules/{category}/{name}/script.sh` with `install()`, `configure()`, and optionally `update()`.
2. Add the path (e.g., `apps/my-app`) to the appropriate `intents/*.txt` file.
3. For configs to symlink, add files under `config/{name}/`.
