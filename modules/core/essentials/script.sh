#!/bin/bash

# Default essentials.

install() {
    log_info "Installing essential tools..."
    local pkgs=(curl jq less ripgrep sed unzip)
    if is_arch; then
        pkgs+=(base-devel)
    elif is_ubuntu; then
        pkgs+=(build-essential)
    fi
    pkg_install "${pkgs[@]}"
}

configure() {
    log_info "No specific configuration for essentials."
}

update() {
    log_info "Updating essential tools..."
    local pkgs=(curl jq less ripgrep sed unzip)
    if is_arch; then
        pkgs+=(base-devel)
    elif is_ubuntu; then
        pkgs+=(build-essential)
    fi
    pkg_update "${pkgs[@]}"
}
