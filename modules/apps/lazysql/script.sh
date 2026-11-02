#!/bin/bash

LAZYSQL_VERSION="0.5.4"

install() {
    if is_arch; then
        pkg_install lazysql
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release lazysql "$LAZYSQL_VERSION" \
        "https://github.com/jorgerojas26/lazysql/releases/download/v{version}/lazysql_Linux_{arch}.tar.gz"
}

configure() {
    : # no config files to symlink
}

update() {
    if is_arch; then
        pkg_update lazysql
    elif is_ubuntu; then
        install_ubuntu
    fi
}
