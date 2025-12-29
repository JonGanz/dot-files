#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Obsidian install for environment without Desktop Environment"
    exit 2;
fi

: "${APPIMAGE_DIR:?APPIMAGE_DIR not set}"
: "${OBSIDIAN_VER:?OBSIDIAN_VER not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

APPIMAGE_NAME="Obsidian-${OBSIDIAN_VER}.AppImage"
APPIMAGE_PATH="$APPIMAGE_DIR/$APPIMAGE_NAME"
DESKTOP_FILE="/usr/share/applications/obsidian.desktop"
OBSIDIAN_BIN="/usr/local/bin/obsidian"
ICON_PATH="/usr/share/pixmaps/obsidian.png"
ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/obsidian.png"

if [[ ! -f "$APPIMAGE_PATH" ]]; then
  wget -O "$APPIMAGE_PATH" \
    "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VER}/${APPIMAGE_NAME}"
fi

sudo install -m 755 "$APPIMAGE_PATH" "$OBSIDIAN_BIN"

sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Obsidian
Comment=Digital Vault
Exec=$OBSIDIAN_BIN
Icon=obsidian
Terminal=false
Categories=
StartupWMClass=obsidian
EOF

sudo chmod 644 "$DESKTOP_FILE"

if [[ ! -f "$ICON_PATH" ]]; then
  sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
  sudo chmod 644 "$ICON_PATH"
fi

