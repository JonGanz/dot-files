#!/bin/bash

install() {
    if is_wsl; then
        log_warn "Skipping MySQL Workbench (GUI) in WSL environment."
        log_info "Installing mysql-client for CLI access..."
        pkg_install mysql-client
        return
    fi

    pkg_install mysql-workbench
}

configure() {
    if ! is_wsl; then
        log_info "Configuring MySQL Workbench..."
    fi
}

update() {
    if ! is_wsl; then
        pkg_update mysql-workbench
    fi
}
