#!/bin/bash

# Lazygit installation and configuration

LAZYGIT_VERSION="0.61.1"

install() {
    if is_arch; then
        pkg_install lazygit
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release lazygit "$LAZYGIT_VERSION" \
        "https://github.com/jesseduffield/lazygit/releases/download/v{version}/lazygit_{version}_Linux_{arch}.tar.gz"
}

configure() {
    symlink_config_dir lazygit "$HOME/.config/lazygit"
}

update() {
    if is_arch; then
        pkg_update lazygit
    elif is_ubuntu; then
        install_ubuntu
    fi
}
