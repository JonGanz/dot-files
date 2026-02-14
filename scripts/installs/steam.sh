#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if is_distro pop; then
    
    sudo apt-get install -y steam
    
elif is_distro ubuntu; then

    if ! command -v steam >/dev/null 2>&1; then
        DEB_FILE_PATH="/tmp/steam.deb"
        curl -fsSL "https://cdn.fastly.steamstatic.com/client/installer/steam.deb" -o "$DEB_FILE_PATH"
        sudo dpkg -i "$DEB_FILE_PATH"
    fi

fi
