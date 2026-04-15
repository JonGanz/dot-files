#!/bin/bash

install() {
    if is_arch; then
        pkg_install neovim
    fi
}

configure() {
    log_info "Configuring neovim..."
    # Placeholder for nvim config
}

update() {
    pkg_update neovim
}
