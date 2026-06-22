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
    if has_cmd lazygit; then
        local current_version
        # Extract version specifically from 'version=', excluding 'git version', and taking only the first match
        current_version=$(lazygit --version | grep -oP '(?<!git )version=\K[0-9][0-9.]*' | head -n 1)
        if [[ "$current_version" == "$LAZYGIT_VERSION" ]]; then
            log_success "lazygit v$LAZYGIT_VERSION is already installed."
            return 0
        fi
        log_info "Updating lazygit from $current_version to $LAZYGIT_VERSION..."
    else
        log_info "Installing lazygit v$LAZYGIT_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${arch}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    log_info "Downloading lazygit from $url..."
    if curl -LSs "$url" -o "$tmp_dir/lazygit.tar.gz"; then
        tar -xzf "$tmp_dir/lazygit.tar.gz" -C "$tmp_dir"
        sudo install "$tmp_dir/lazygit" /usr/local/bin/lazygit
        log_success "lazygit v$LAZYGIT_VERSION installed to /usr/local/bin/lazygit"
    else
        log_error "Failed to download lazygit."
    fi
    
    rm -rf "$tmp_dir"
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
