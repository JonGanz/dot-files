#!/usr/bin/env bash
set -euo pipefail

: "${OPEN_SOURCE_DIR:?OPEN_SOURCE_DIR not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if [[ $OS == "arch" ]]; then
    
    DIR="$OPEN_SOURCE_DIR/yay"

    ensure_directory "$DIR"
    pushd "$DIR"

    if [ ! -d "$DIR/.git" ]; then
        git clone https://aur.archlinux.org/yay.git "$DIR"
    fi

    git fetch --prune
    git rebase

    makepkg -si
    popd

fi

