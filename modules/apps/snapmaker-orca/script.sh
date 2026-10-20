#!/bin/bash

ORCA_VERSION="2.4.0"
ORCA_URL="https://github.com/Snapmaker/OrcaSlicer/releases/download/v${ORCA_VERSION}/Snapmaker_Orca-Linux-flatpak_V${ORCA_VERSION}_x86_64.flatpak"
ORCA_SHA256="17ed65ca8da5bc081f16d19e30fee892f4ef58eb48589297f41941c2815fb011"
ORCA_MARKER="$HOME/.local/state/snapmaker-orca/installed.sha256"

install() {
    if is_wsl; then
        log_warn "Skipping Snapmaker Orca (GUI) in WSL environment."
        return
    fi

    if ! has_cmd flatpak; then
        pkg_install flatpak
    fi

    if [ -f "$ORCA_MARKER" ] && [ "$(cat "$ORCA_MARKER")" = "$ORCA_SHA256" ]; then
        log_success "Snapmaker Orca v$ORCA_VERSION is already installed."
        return
    fi

    local tmp_dir bundle
    tmp_dir=$(mktemp -d)
    bundle="$tmp_dir/snapmaker-orca.flatpak"

    log_info "Downloading Snapmaker Orca v$ORCA_VERSION..."
    if ! curl -fSL "$ORCA_URL" -o "$bundle"; then
        log_error "Failed to download Snapmaker Orca from $ORCA_URL"
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! echo "$ORCA_SHA256  $bundle" | sha256sum -c --status; then
        log_error "SHA256 mismatch for Snapmaker Orca bundle; refusing to install."
        rm -rf "$tmp_dir"
        return 1
    fi

    log_info "Installing Snapmaker Orca v$ORCA_VERSION via flatpak..."
    if flatpak install --user -y --or-update "$bundle"; then
        mkdir -p "$(dirname "$ORCA_MARKER")"
        echo "$ORCA_SHA256" > "$ORCA_MARKER"
        log_success "Snapmaker Orca v$ORCA_VERSION installed."
    else
        log_error "flatpak failed to install Snapmaker Orca."
    fi

    rm -rf "$tmp_dir"
}

configure() {
    :
}

update() {
    install
}
