#!/usr/bin/env bash
set -euo pipefail

: "${NEOVIM_VERSION:?NEOVIM_VERSION not set}"
: "${OPEN_SOURCE_DIR:?OPEN_SOURCE_DIR not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if [[ $OS == "ubuntu" ]]; then

    CURRENT_VERSION=$(nvim --version | sed -E 's/NVIM v([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/g' | head -n 1)
    DIR="$OPEN_SOURCE_DIR/neovim"

    if [[ $NEOVIM_VERSION == $CURRENT_VERSION ]]; then
        exit 0
    fi

    ensure_directory "$DIR"
    pushd "$DIR"

    if [ ! -d "$DIR/.git" ]; then
        git clone https://github.com/neovim/neovim.git "$DIR"
    fi

    git fetch --prune
    git checkout "v$NEOVIM_VERSION"

    sudo apt install -y \
        build-essential \
        cmake \
        curl \
        gettext \
        ninja-build \
        unzip

    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    popd

elif [[ $OS == "arch" ]]; then
    
    sudo pacman -S --noconfirm --needed neovim

fi

ensure_symlink_dir "$SETUP_DIR/dotfiles/nvim" "$HOME/.config/nvim"

