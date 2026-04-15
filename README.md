# Linux Setup System

A modular, idempotent, and multi-platform Bash-based setup system for Linux environments (Arch, Ubuntu/Kubuntu, and WSL2). This project provides an automated way to configure applications, fonts, and themes with support for different machine "intents" (e.g., Personal vs. Work).

## Core Features

-   **Modular Design**: Every application or configuration set is an isolated module.
-   **Multi-Platform**: Unified interface for `pacman` (Arch) and `apt` (Ubuntu/Kubuntu).
-   **WSL2 Aware**: Automatically detects WSL environments to skip GUI-heavy applications or apply specific tweaks.
-   **Intent-Based**: Group modules into profiles like `personal` or `work`.
-   **Idempotent**: Scripts are designed to be safe to run multiple times.
-   **Fast & Low-Level**: Pure Bash implementation with no heavy dependencies like Ansible or Python.

## Project Structure

```text
.
├── setup.sh                 # Main entry point
├── lib/                     # Shared Bash libraries
│   ├── env.sh               # OS & WSL detection
│   ├── log.sh               # Colored logging utilities
│   ├── pkg.sh               # Package manager abstraction
│   └── util.sh              # General utilities (symlinking, etc.)
├── intents/                 # Profile definitions (common, personal, work)
├── modules/                 # Modular installation scripts
│   ├── core/                # Essential tools (Git, Neovim)
│   ├── apps/                # GUI and CLI applications
│   └── ...
└── config/                  # Configuration templates and dotfiles
```

## Usage

### Basic Setup
Run the default setup (includes `common` intent):
```bash
./setup.sh
```

### With Intent
Specify an intent to include additional modules:
```bash
./setup.sh --intent personal
```

### Update Mode
Run update routines for all active modules:
```bash
./setup.sh --update
```

### Single Module
Run only a specific module (useful for testing or targeted updates):
```bash
./setup.sh --only core/neovim
```

### Dry Run
See what would happen without executing any commands:
```bash
./setup.sh --intent work --dry-run
```

## Creating a New Module

Every module must have a `script.sh` in its directory following this pattern:

```bash
#!/bin/bash

# Required: Installation logic
install() {
    if is_wsl; then
        log_warn "Skipping GUI app in WSL."
        return
    fi
    pkg_install my-app
}

# Optional: Configuration logic (e.g., symlinking dotfiles)
configure() {
    log_info "Configuring my-app..."
}

# Optional: Update logic
update() {
    pkg_update my-app
}
```

Add your module path (e.g., `apps/my-app`) to one of the files in `intents/` to include it in a setup profile.

## Supported Platforms

-   **Arch Linux**: Primary support via `pacman`.
-   **Ubuntu / Kubuntu**: Support via `apt`.
-   **WSL2**: Automatic detection and filtering of GUI applications.
-   **Flatpak**: Integrated support for cross-distro application management.
