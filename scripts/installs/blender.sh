#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Blender install for environment without Desktop Environment"
    exit 2;
fi

if is_distro ubuntu; then

    if command -v blender >/dev/null 2>&1; then
        exit 0
    fi

    sudo apt-get install -y blender

elif is_distro arch; then

    sudo pacman -S --noconfirm --needed blender

fi

