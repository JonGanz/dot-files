#!/bin/bash

# Zellij installation and configuration

ZELLIJ_VERSION="0.42.2"

install() {
    if is_arch; then
        pkg_install zellij
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd zellij; then
        local current_version
        current_version=$(zellij --version | awk '{print $2}')
        if [[ "$current_version" == "$ZELLIJ_VERSION" ]]; then
            log_success "zellij v$ZELLIJ_VERSION is already installed."
            return 0
        fi
        log_info "Updating zellij from $current_version to $ZELLIJ_VERSION..."
    else
        log_info "Installing zellij v$ZELLIJ_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-${arch}-unknown-linux-musl.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Downloading zellij from $url..."
    if curl -LSs "$url" -o "$tmp_dir/zellij.tar.gz"; then
        tar -xzf "$tmp_dir/zellij.tar.gz" -C "$tmp_dir"
        sudo install "$tmp_dir/zellij" /usr/local/bin/zellij
        log_success "zellij v$ZELLIJ_VERSION installed to /usr/local/bin/zellij"
    else
        log_error "Failed to download zellij."
    fi

    rm -rf "$tmp_dir"
}

configure() {
    log_info "Configuring zellij..."

    mkdir -p "$HOME/.config"

    symlink_file "$DIR/config/zellij" "$HOME/.config/zellij"
}

update() {
    if is_arch; then
        pkg_update zellij
    elif is_ubuntu; then
        install_ubuntu
    fi
}
