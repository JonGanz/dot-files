#!/bin/bash

# Rust toolchain installation via rustup

install() {
    if is_arch; then
        log_info "Installing rustup via pacman..."
        pkg_install rustup
    elif is_ubuntu; then
        if ! has_cmd rustup; then
            log_info "Installing rustup via official shell script..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        else
            log_success "rustup is already installed."
        fi
    fi
}

configure() {
    log_info "Configuring Rust toolchain..."

    # Source SDK environment for the current subshell
    if [ -f "$DIR/modules/sdks/rust/env.sh" ]; then
        source "$DIR/modules/sdks/rust/env.sh"
    fi

    if has_cmd rustup; then
        log_info "Ensuring stable toolchain is installed..."
        rustup default stable
        log_success "Rust $(rustc --version) is ready."

        bashrc_d_link "$DIR/modules/sdks/rust/env.sh" rust
    else
        log_error "rustup command not found after installation."
    fi
}

update() {
    log_info "Updating Rust toolchains..."
    if [ -f "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
    fi
    
    if has_cmd rustup; then
        rustup update
    else
        install
    fi
}
