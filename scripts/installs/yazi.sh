#!/usr/bin/env bash
set -euo pipefail

# TODO: Add a version number that we are going to checkout.
: "${OPEN_SOURCE_DIR:?OPEN_SOURCE_DIR not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if [[ "$OS" == "ubuntu" ]]; then
    
    DIR="$OPEN_SOURCE_DIR/yazi"

    ensure_directory "$DIR"
    pushd "$DIR"

    if [ ! -d "$DIR/.git" ]; then
        git clone https://github.com/sxyazi/yazi.git "$DIR"
    fi

    git fetch --prune
    git rebase

    cargo build --release --locked

    ensure_symlink_file "$DIR/target/release/yazi" "$HOME/.local/bin/yazi"
    ensure_symlink_file "$DIR/target/release/ya" "$HOME/.local/bin/ya"

    popd

elif [[ "$OS" == "arch" ]]; then

    sudo pacman -S --noconfirm --needed \
        yazi \
        7zip \
        fd \
        ffmpeg \
        fzf \
        imagemagick \
        jq \
        poppler \
        resvg \
        ripgrep \
        zoxide

fi

