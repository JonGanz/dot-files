#!/bin/bash

# Default essentials.

ESSENTIAL_PKGS=(
    bats
    curl
    dos2unix
    ffmpeg
    fzf
    imagemagick
    jq
    less
    ripgrep
    sed
    tree
    unzip
)

# Platform-specific additions, resolved at call time
essential_pkgs() {
    local pkgs=("${ESSENTIAL_PKGS[@]}")
    if is_arch; then
        pkgs+=(base-devel)
    elif is_ubuntu; then
        pkgs+=(
            build-essential
            linux-tools-common
            linux-tools-generic
            ncal
            nfs-common
            resvg
        )
    fi
    printf '%s\n' "${pkgs[@]}"
}

install() {
    mapfile -t pkgs < <(essential_pkgs)
    pkg_install "${pkgs[@]}"
}

update() {
    mapfile -t pkgs < <(essential_pkgs)
    pkg_update "${pkgs[@]}"
}
