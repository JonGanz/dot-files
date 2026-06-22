#!/bin/bash

# oh-my-posh installation and configuration

POSH_VERSION="29.10.0"

install() {
    if is_arch; then
        pkg_install oh-my-posh-bin
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd oh-my-posh; then
        local current_version
        current_version=$(oh-my-posh --version)
        if [[ "$current_version" == "$POSH_VERSION" ]]; then
            log_success "oh-my-posh v$POSH_VERSION is already installed."
            return 0
        fi
        log_info "Updating oh-my-posh from $current_version to $POSH_VERSION..."
    else
        log_info "Installing oh-my-posh v$POSH_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${POSH_VERSION}/posh-linux-${arch}"
    
    log_info "Downloading oh-my-posh from $url..."
    if sudo curl -LSs "$url" -o /usr/local/bin/oh-my-posh; then
        sudo chmod +x /usr/local/bin/oh-my-posh
        log_success "oh-my-posh v$POSH_VERSION installed to /usr/local/bin/oh-my-posh"
    else
        log_error "Failed to download oh-my-posh."
    fi
}

configure() {
    log_info "Configuring oh-my-posh..."
    
    local config_dir="$HOME/.config/ohmyposh"
    mkdir -p "$config_dir"
    
    local repo_theme="$DIR/config/ohmyposh/theme.omp.json"
    local dest_theme="$config_dir/theme.omp.json"
    
    if [ -f "$repo_theme" ]; then
        symlink_file "$repo_theme" "$dest_theme"
    else
        log_warn "Theme file not found at $repo_theme"
    fi

    # Add initialization to .bashrc
    if ! grep -q "oh-my-posh init bash" "$HOME/.bashrc"; then
        log_info "Adding oh-my-posh initialization to .bashrc..."
        echo 'eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/theme.omp.json)"' >> "$HOME/.bashrc"
    fi
}

update() {
    if is_arch; then
        pkg_update oh-my-posh-bin
    elif is_ubuntu; then
        install_ubuntu
    fi
}
