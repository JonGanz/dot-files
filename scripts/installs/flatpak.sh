#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if is_distro ubuntu; then

    sudo apt install -y \
        flatpak \
        gnome-software-plugin-flatpak

    flatpak remote-add \
        --system \
        --if-not-exists \
        flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

elif is_distro arch; then

    sudo pacman -S --noconfirm --needed \
        flatpak

fi

