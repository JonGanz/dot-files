#!/bin/bash

LAZYDOCKER_VERSION="0.25.2"

install() {
    if is_arch; then
        pkg_install lazydocker
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release lazydocker "$LAZYDOCKER_VERSION" \
        "https://github.com/jesseduffield/lazydocker/releases/download/v{version}/lazydocker_{version}_Linux_{arch}.tar.gz"
}


update() {
    if is_arch; then
        pkg_update lazydocker
    elif is_ubuntu; then
        install_ubuntu
    fi
}
