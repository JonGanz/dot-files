#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Discord install for environment without Desktop Environment"
    exit 2;
fi

DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"

if is_distro ubuntu; then

    if ! command -v discord >/dev/null 2>&1; then
        DEB_FILE_PATH="/tmp/discord.deb"
        curl -fsSL "$DISCORD_URL" -o "$DEB_FILE_PATH"
        sudo dpkg -i "$DEB_FILE_PATH"
    fi

fi
