#!/bin/bash

install() {
    if is_wsl; then
        log_warn "Skipping Steam (GUI) in WSL environment."
        return
    fi

    if is_arch; then
        # Ensure multilib is enabled
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
            log_info "Enabling multilib repository in /etc/pacman.conf..."
            # Using sed to uncomment the multilib section
            # This is a bit risky to do automatically without a backup, but fits the "ensure" goal
            sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
            sudo pacman -Sy
        fi
    elif is_ubuntu; then
        # Ensure multiverse is enabled (often needed for Steam on Ubuntu)
        if ! grep -q "^deb.*multiverse" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            log_info "Enabling multiverse repository..."
            sudo add-apt-repository -y multiverse
            sudo apt-get update
        fi
    fi

    pkg_install steam
}

configure() {
    if ! is_wsl; then
        log_info "Configuring Steam..."
    fi
}

update() {
    if ! is_wsl; then
        pkg_update steam
    fi
}
