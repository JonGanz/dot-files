#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Ghostty install for environment without Desktop Environment"
    exit 1;
fi

: "${APPIMAGE_DIR:?APPIMAGE_DIR not set}"
: "${GHOSTTY_VER:?GHOSTTY_VER not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

APPIMAGE_NAME="Ghostty-${GHOSTTY_VER}-x86_64.AppImage"
APPIMAGE_PATH="$APPIMAGE_DIR/$APPIMAGE_NAME"
DESKTOP_FILE="/usr/share/applications/ghostty.desktop"
GHOSTTY_BIN="/usr/local/bin/ghostty"
ICON_PATH="/usr/share/pixmaps/ghostty.png"
ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ghostty.png"

if [[ ! -f "$APPIMAGE_PATH" ]]; then
  wget -O "$APPIMAGE_PATH" \
    "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v${GHOSTTY_VER}/${APPIMAGE_NAME}"
fi

sudo install -m 755 "$APPIMAGE_PATH" "$GHOSTTY_BIN"

sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Ghostty
Comment=GPU-accelerated terminal emulator
Exec=$GHOSTTY_BIN
Icon=ghostty
Terminal=false
Categories=System;TerminalEmulator;
StartupWMClass=ghostty
EOF

sudo chmod 644 "$DESKTOP_FILE"

if [[ ! -f "$ICON_PATH" ]]; then
  sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
  sudo chmod 644 "$ICON_PATH"
fi

ensure_symlink_dir "$SETUP_DIR/dotfiles/ghostty" "$HOME/.config/ghostty"

