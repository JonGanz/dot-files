#!/usr/bin/env bash
set -euo pipefail

if [[ $OS == "ubuntu" ]]; then

    sudo apt install -y \
        flatpak \
        gnome-software-plugin-flatpak

    flatpak remote-add \
        --system \
        --if-not-exists \
        flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

elif [[ $OS == "arch" ]]; then

    sudo pacman -S --noconfirm --needed \
        flatpak

fi

