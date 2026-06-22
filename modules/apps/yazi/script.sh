#!/bin/bash

# Yazi TUI File Explorer

install() {
    if is_arch; then
        pkg_install yazi
    elif is_ubuntu; then
        if ! has_cmd yazi; then
            log_info "Building Yazi from source via Cargo..."

            # Ensure Rust is available
            refresh_envs

            if ! has_cmd cargo; then
                log_error "Cargo not found. Rust must be installed before Yazi."
                return 1
            fi

            # Install build dependencies
            pkg_install build-essential

            # Install Yazi via Cargo
            cargo install --force yazi-build
        else
            log_success "Yazi is already installed."
        fi
    fi
}

configure() {
    log_info "Configuring yazi..."
    # Placeholder for potential yazi configuration
}

update() {
    if is_arch; then
        pkg_update yazi
    elif is_ubuntu; then
        refresh_envs
        cargo install --force yazi-build
    fi
}
