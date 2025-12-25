#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping web-app install for environment without Desktop Environment"
    exit 2;
fi

: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

setup_webapp() {
    local APP_NAME="$1"
    local APP_URL="$2"
    local ICON_URL="$3"

    local ICON_DIR="$HOME/.local/share/applications/icons"
    local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
    local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"

    ensure_directory "$ICON_DIR"

    if [[ ! -f "$ICON_PATH" ]]; then
      sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
      sudo chmod 644 "$ICON_PATH"
    fi

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=brave-browser --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

    chmod +x "$DESKTOP_FILE"
}

setup_webapp "WhatsApp" "https://web.whatsapp.com" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/whatsapp.png"
setup_webapp "YouTube" "https://youtube.com" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png"

