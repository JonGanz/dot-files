#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Multimedia Suite install for environment without Desktop Environment"
    exit 2;
fi

if [[ $OS == "ubuntu" ]]; then

    sudo apt install -y \
        gimp \
        inkscape

elif [[ $OS == "arch" ]]; then

    sudo pacman -S --noconfirm --needed \
        gimp \
        inkscape

fi

