#!/usr/bin/env bash
set -uo pipefail

source "$SETUP_DIR/bash/ensure.sh"

ensure_symlink_dir "$SETUP_DIR/wallpapers/gruvbox/dark" "/usr/local/share/wallpapers"

ensure_symlink_file "$SETUP_DIR/dotfiles/kde/kdeglobals" "$HOME/.config/kdeglobals"
ensure_symlink_file "$SETUP_DIR/dotfiles/kde/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc"
ensure_symlink_file "$SETUP_DIR/dotfiles/kde/kwinrc" "$HOME/.config/kwinrc"
ensure_symlink_file "$SETUP_DIR/dotfiles/kde/plasma-org.kde.plasma.desktop-appletsrc" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
ensure_symlink_file "$SETUP_DIR/dotfiles/kde/plasmarc" "$HOME/.config/plasmarc"

