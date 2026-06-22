# 🐧 Linux Setup System

A modular, idempotent, and multi-platform Bash-based setup system for Linux environments (Arch, Ubuntu/Kubuntu, and WSL2). This project provides an automated way to configure applications, fonts, and themes with support for different machine "intents" (e.g., Personal vs. Work).

---

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JonGanz/dot-files.git ~/setup && cd ~/setup
   ```

2. **Run the setup:**
   ```bash
   ./setup.sh
   ```
   *On the first run, you will be prompted for basic configuration like your Git name and email.*

---

## ✨ Key Features

-   **🎯 Intent-Based**: Group modules into profiles like `personal` or `work` to customize your environment for the task at hand.
-   **📦 Package Abstraction**: Unified interface for `pacman` (Arch) and `apt` (Ubuntu/Kubuntu).
-   **🪟 WSL2 Aware**: Automatically detects WSL environments to skip GUI-heavy applications or apply specific tweaks.
-   **🔄 Idempotent**: Scripts are designed to be safe to run multiple times without side effects.
-   **🧩 Modular Design**: Every application or configuration set is an isolated module.
-   **⚡ Fast & Low-Level**: Pure Bash implementation with no heavy dependencies like Ansible or Python.

---

## 🛠 Usage

### Command Line Options

| Option | Description |
| :--- | :--- |
| `--intent <name>` | Set the intent (e.g., `personal`, `work`). Default: `common` |
| `--update` | Run update routines for all active modules. |
| `--only <module>` | Run only a specific module (e.g., `core/neovim`). |
| `--reconfigure` | Force a prompt for all configuration values. |
| `--dry-run` | Show what would happen without executing any commands. |
| `--help` | Show the help message. |

### Examples

**Standard setup with work tools:**
```bash
./setup.sh --intent work
```

**Update Neovim only:**
```bash
./setup.sh --only core/neovim --update
```

**Preview a full setup:**
```bash
./setup.sh --intent personal --dry-run
```

---

## ⚙️ Configuration

The system includes an interactive configuration layer. On the first run (or when using `--reconfigure`), you will be asked for:
- **Git User Name/Email**: Used for global git configuration.
- **Work Directory**: Path to your primary coding workspace.

These values are saved to `.local.env` (which is git-ignored) and can be used in templates throughout your modules.

---

## 📂 Project Structure

```text
.
├── setup.sh                 # Main entry point
├── lib/                     # Shared Bash libraries
│   ├── env.sh               # OS & WSL detection
│   ├── log.sh               # Colored logging utilities
│   ├── pkg.sh               # Package manager abstraction
│   ├── config.sh            # Configuration management
│   └── util.sh              # General utilities (symlinking, etc.)
├── intents/                 # Profile definitions (common, personal, work)
├── modules/                 # Modular installation scripts
│   ├── core/                # Essential tools (Git, Neovim)
│   ├── apps/                # GUI and CLI applications
│   └── sdks/                # Language runtimes (Node, Go, Rust)
└── config/                  # Configuration templates and dotfiles
```

---

## 🛠 Creating a New Module

Modules live in `modules/` and must contain a `script.sh`.

```bash
#!/bin/bash

# Required: Installation logic
install() {
    # Skip GUI apps in WSL
    if is_wsl; then
        log_warn "Skipping GUI app in WSL."
        return
    fi
    
    pkg_install my-app
}

# Optional: Configuration logic
configure() {
    log_info "Configuring my-app..."
    
    # Symlink a config file
    symlink_file "$DIR/config/my-app/config.conf" "$HOME/.config/my-app/config.conf"
    
    # Render a template with config variables
    render_template "$DIR/config/my-app/profile.tmpl" "$HOME/.config/my-app/profile"
}

# Optional: Update logic
update() {
    pkg_update my-app
}
```

Add your module path (e.g., `apps/my-app`) to `intents/common.txt` (or another intent file) to enable it.

---

## ✅ Supported Platforms

-   **Arch Linux**: Full support via `pacman`.
-   **Ubuntu / Kubuntu**: Full support via `apt`.
-   **WSL2**: Automatic detection and filtering of GUI applications.
-   **Flatpak**: Integrated support for cross-distro apps (`flatpak_install`).
