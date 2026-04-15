#!/bin/bash

install() {
    if is_wsl; then
        log_warn "Skipping GIMP (GUI) in WSL environment."
        return
    fi

    pkg_install gimp
}

configure() {
    if ! is_wsl; then
        log_info "Configuring GIMP..."
    fi
}

update() {
    if ! is_wsl; then
        pkg_update gimp
    fi
}
