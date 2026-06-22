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
```

There is no test suite. Validation is done by running with `--dry-run` first or targeting a single module.

## Architecture

### Execution Flow

`setup.sh` sources all `lib/` files, parses args, then calls `run_module()` for each entry in the active intent file(s). Each module runs in a subshell with all libs re-sourced, so state cannot leak between modules.

Intent files (`intents/common.txt`, `intents/personal.txt`, `intents/work.txt`) are plain text lists of module paths. `common` always runs; the selected intent's file is appended. Duplicates are deduplicated while preserving order.

### Module Contract

Every module lives at `modules/{category}/{name}/script.sh` and must define:

```bash
install()    # Required — package installation
configure()  # Required — symlinking configs, writing to .bashrc, etc.
update()     # Optional — if absent, install+configure is called on --update
```

Modules are sourced (not executed), so functions share the lib namespace. Use the `is_wsl`, `is_arch`, `is_ubuntu` helpers from `lib/env.sh` to branch platform-specific logic. Always guard GUI apps with `is_wsl` early-return.

### Shared Libraries

| File | Purpose |
|---|---|
| `lib/env.sh` | `is_arch()`, `is_ubuntu()`, `is_wsl()`, `detect_env()` |
| `lib/log.sh` | `log_info/warn/error/success/step` — colored output |
| `lib/pkg.sh` | `pkg_install`, `pkg_update`, `flatpak_install`, `has_cmd`, `has_pkg` |
| `lib/util.sh` | `symlink_file`, `render_template`, `refresh_envs` |
| `lib/config.sh` | `load_config`, `save_config`, `ensure_config`, `reconfigure` |

### Configuration System

User-specific values (git name/email, work directory) are stored in `.local.env` (gitignored). The `CONFIG_ITEMS` array in `lib/config.sh` defines what gets prompted. Config values are exported as shell variables and available inside modules after `load_config` runs.

Config templates use `{{ variable_name }}` placeholders. `render_template src dest` replaces these with values from `CONFIG_ITEMS` variables.

`refresh_envs` sources `modules/sdks/*/env.sh` to make SDK tools (cargo, nvm, go) available within the current subshell — call this before using a tool installed by a prior module.

### SDK Environment Files

Each SDK module that modifies PATH has a companion `modules/sdks/{name}/env.sh` that sets up the environment for that SDK. These are sourced by `refresh_envs` so later modules can use tools from earlier SDK installs within the same run.

### Adding a Module

1. Create `modules/{category}/{name}/script.sh` with `install()`, `configure()`, and optionally `update()`.
2. Add the path (e.g., `apps/my-app`) to the appropriate `intents/*.txt` file.
3. For configs to symlink, add files under `config/{name}/`.
