#!/bin/bash

# Zellij installation and configuration

ZELLIJ_VERSION="0.42.2"

install() {
    if is_arch; then
        pkg_install zellij
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release zellij "$ZELLIJ_VERSION" \
        "https://github.com/zellij-org/zellij/releases/download/v{version}/zellij-{arch_native}-unknown-linux-musl.tar.gz"
}

configure() {
    mkdir -p "$HOME/.config"

    symlink_file "$DIR/config/zellij" "$HOME/.config/zellij"
}

update() {
    if is_arch; then
        pkg_update zellij
    elif is_ubuntu; then
        install_ubuntu
    fi
}
