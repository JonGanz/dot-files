#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Jellyfin install for environment without Desktop Environment"
    exit 2;
fi

DESKTOP_FILE="/usr/share/applications/jellyfin.desktop"
JELLYFIN_BIN="flatpak run com.github.iwalton3.jellyfin-media-player"
ICON_PATH="/usr/share/pixmaps/jellyfin.png"
ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png"

flatpak install -y --noninteractive flathub com.github.iwalton3.jellyfin-media-player

sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Jellyfin
Comment=Self-hosted video streaming service
Exec=$JELLYFIN_BIN
Icon=jellyfin
Terminal=false
EOF

sudo chmod 644 "$DESKTOP_FILE"

if [[ ! -f "$ICON_PATH" ]]; then
  sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
  sudo chmod 644 "$ICON_PATH"
fi

