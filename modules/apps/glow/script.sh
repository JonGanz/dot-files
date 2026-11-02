#!/bin/bash

GLOW_VERSION="2.1.2"

install() {
    if is_arch; then
        pkg_install glow
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release glow "$GLOW_VERSION" \
        "https://github.com/charmbracelet/glow/releases/download/v{version}/glow_{version}_Linux_{arch}.tar.gz" \
        "glow_${GLOW_VERSION}_Linux_$(get_arch)/glow"
}


update() {
    if is_arch; then
        pkg_update glow
    elif is_ubuntu; then
        install_ubuntu
    fi
}
