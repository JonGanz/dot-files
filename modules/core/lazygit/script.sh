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
    log_info "Configuring lazygit..."
    
    # Standard lazygit config location
    local config_dir="$HOME/.config/lazygit"
    mkdir -p "$config_dir"
    
    # We expect config files in config/lazygit/ inside our repo
    local repo_config="$DIR/config/lazygit"
    
    if [ -d "$repo_config" ]; then
        for file in "$repo_config"/*; do
            if [ -f "$file" ]; then
                symlink_file "$file" "$config_dir/$(basename "$file")"
            fi
        done
    else
        log_warn "No lazygit configuration found in $repo_config"
    fi
}

update() {
    if is_arch; then
        pkg_update lazygit
    elif is_ubuntu; then
        install_ubuntu
    fi
}
