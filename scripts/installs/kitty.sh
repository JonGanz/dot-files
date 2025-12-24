#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Kitty install for environment without Desktop Environment"
    exit 1;
fi

: "${OPEN_SOURCE_DIR:?OPEN_SOURCE_DIR not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

DIR="$OPEN_SOURCE_DIR/kitty"

if [[ $OS == "ubuntu" ]]; then
    ensure_directory "$DIR"
    pushd "$DIR"

    if [ ! -d "$DIR/.git" ]; then
        git clone https://github.com/kovidgoyal/kitty.git "$DIR"
    fi

    sudo apt install -y \
        build-essential \
        libcairo2-dev \
        libdbus-1-dev \
        libfontconfig-dev \
        libfontconfig-dev \
        libgl1-mesa-dev \
        liblcms2-dev \
        libpython3-dev \
        libsimde-dev \
        libsimde-dev \
        libssl-dev \
        libx11-xcb-dev \
        libxcursor-dev \
        libxi-dev \
        libxinerama-dev \
        libxkbcommon-x11-dev \
        libxrandr-dev \
        libxxhash-dev \
        pkg-config

    ./dev.sh build
    popd
fi

