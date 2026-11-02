#!/bin/bash

# System-wide Font Installation (JetBrains Mono Nerd Font)

JETBRAINS_FONT_VERSION="3.4.0"

install() {
    if is_wsl; then
        log_warn "Skipping Font installation in WSL environment."
        return
    fi

    if is_arch; then
        pkg_install ttf-jetbrains-mono-nerd
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    local font_name="JetBrainsMono"
    local font_dir="/usr/local/share/fonts/$font_name"
    local marker="$font_dir/.version"

    if [ -f "$marker" ] && [ "$(cat "$marker")" = "$JETBRAINS_FONT_VERSION" ]; then
        log_success "$font_name Nerd Font v$JETBRAINS_FONT_VERSION is already installed."
        return 0
    fi

    log_info "Installing $font_name Nerd Font v$JETBRAINS_FONT_VERSION..."

    # Ensure dependencies
    pkg_install curl unzip fontconfig

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local zip_file="$tmp_dir/$font_name.zip"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${JETBRAINS_FONT_VERSION}/${font_name}.zip"

    local status=0
    if download_file "$url" "$zip_file"; then
        sudo rm -rf "$font_dir"
        sudo mkdir -p "$font_dir"
        sudo unzip -oq "$zip_file" -d "$font_dir"
        # Remove unwanted files
        sudo rm -f "$font_dir"/*.txt "$font_dir"/*.md
        echo "$JETBRAINS_FONT_VERSION" | sudo tee "$marker" > /dev/null
        log_success "$font_name Nerd Font files extracted to $font_dir"
    else
        status=1
    fi

    rm -rf "$tmp_dir"
    return "$status"
}

configure() {
    log_info "Refreshing font cache..."
    if has_cmd fc-cache; then
        sudo fc-cache -fv > /dev/null
        log_success "Font cache refreshed."
    else
        log_warn "fc-cache command not found. Skipping font cache refresh."
    fi
}

update() {
    # Fonts don't change often, but re-running install will check if dir exists
    install
}
