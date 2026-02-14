#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Readest install for environment without Desktop Environment"
    exit 2;
fi

DESKTOP_FILE="/usr/share/applications/readest.desktop"
READEST_BIN="flatpak run com.bilingify.readest"
ICON_PATH="/usr/share/pixmaps/readest.png"
# ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png"

flatpak install \
    -y \
    --noninteractive \
    --user flathub \
    com.bilingify.readest

sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Readest
Comment=eReader
Exec=$READEST_BIN
Terminal=false
EOF

sudo chmod 644 "$DESKTOP_FILE"

# if [[ ! -f "$ICON_PATH" ]]; then
#     sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
#     sudo chmod 644 "$ICON_PATH"
# fi

