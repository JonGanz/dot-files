#!/bin/bash

install() {
    if is_arch; then
        pkg_install neovim
    fi
}

configure() {
    log_info "Configuring neovim..."
    link_config "config/nvim" "$HOME/.config/nvim"
}

update() {
    pkg_update neovim
}
