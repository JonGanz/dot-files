#!/bin/bash

install() {
    if is_wsl; then
        log_warn "Skipping Wezterm (GUI) in WSL environment."
        return
    fi

    if is_arch; then
        pkg_install wezterm
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    log_info "Installing Wezterm via APT..."

    # Add official GPG key if not present
    if [ ! -f /etc/apt/keyrings/wezterm-fury.gpg ]; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
    fi

    # Add the repository if not present
    if [ ! -f /etc/apt/sources.list.d/wezterm.list ]; then
        log_info "Adding Wezterm repository..."

        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | \
            sudo tee /etc/apt/sources.list.d/wezterm.list

        pkg_repo_update wezterm
    fi

    pkg_install wezterm
}

configure() {
    log_info "Configuring Wezterm..."

    local config_dir="$HOME"
    local dest_config="$config_dir/.wezterm.lua"
    local repo_config="$DIR/config/wezterm/.wezterm.lua"

    if [ -f "$repo_config" ]; then
        symlink_file "$repo_config" "$dest_config"
    else
        log_warn "Config file not found at $repo_config"
    fi
}

update() {
    if is_arch; then
        pkg_update wezterm
    elif is_ubuntu; then
        pkg_update wezterm
    fi
}
