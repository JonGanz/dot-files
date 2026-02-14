#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if is_distro arch; then

    sudo pacman -S --noconfirm --needed \
        base-devel \
        curl \
        ffmpeg \
        jq \
        less \
        ripgrep \
        tmux \
        sed \
        unzip

elif is_distro ubuntu; then
    
    sudo apt-get install -y \
        curl \
        jq \
        ffmpeg \
        less \
        linux-tools-common \
        linux-tools-generic \
        ncal \
        nfs-common \
        ripgrep \
        sed \
        tmux \
        unzip

fi

ensure_symlink_dir "$SETUP_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"

