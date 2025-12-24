#!/usr/bin/env bash
set -euo pipefail

: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if [[ $OS == "arch" ]]; then

    sudo pacman -S --noconfirm --needed \
        base-devel \
        curl \
        jq \
        less \
        ripgrep \
        tmux \
        sed \
        unzip

elif [[ $OS == "ubuntu" ]]; then
    
    sudo apt-get install -y \
        curl \
        jq \
        less \
        ncal \
        ripgrep \
        tmux \
        sed \
        unzip

fi

ensure_symlink_dir "$SETUP_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"

