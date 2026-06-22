#!/bin/bash

NVIM_VERSION="0.11.4"

install() {
    if is_arch; then
        pkg_install neovim
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd nvim; then
        local current_version
        current_version=$(nvim --version | head -n 1 | awk '{print $2}' | sed 's/^v//')
        if [[ "$current_version" == "$NVIM_VERSION" ]]; then
            log_success "Neovim v$NVIM_VERSION is already installed."
            return 0
        fi
        log_info "Updating Neovim from $current_version to $NVIM_VERSION..."
    else
        log_info "Installing Neovim v$NVIM_VERSION from source..."
    fi

    # Install build dependencies
    pkg_install curl cmake gettext ninja-build unzip

    # Create a temporary directory for the build
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1

    log_info "Downloading Neovim v$NVIM_VERSION source..."
    curl -LO "https://github.com/neovim/neovim/archive/refs/tags/v$NVIM_VERSION.tar.gz"
    tar xzf "v$NVIM_VERSION.tar.gz"
    cd "neovim-$NVIM_VERSION" || exit 1

    log_info "Building Neovim (this may take a minute)..."
    make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)
    
    log_info "Installing Neovim..."
    sudo make install

    # Clean up
    cd "$DIR" || exit 1
    rm -rf "$tmp_dir"
    
    log_success "Neovim v$NVIM_VERSION installed successfully!"
}

configure() {
    log_info "Configuring neovim..."
    # Ensure the config directory exists
    mkdir -p "$HOME/.config"
    
    # Symlink the nvim config from our repo to ~/.config/nvim
    symlink_file "$DIR/config/nvim" "$HOME/.config/nvim"
}

update() {
    if is_arch; then
        pkg_update neovim
    elif is_ubuntu; then
        # Re-run install to check version and update if necessary
        install_ubuntu
    fi
}
