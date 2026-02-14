#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Multimedia Suite install for environment without Desktop Environment"
    exit 2;
fi

if is_distro ubuntu; then

    sudo apt install -y \
        gimp \
        inkscape

elif is_distro arch; then

    sudo pacman -S --noconfirm --needed \
        gimp \
        inkscape

fi

