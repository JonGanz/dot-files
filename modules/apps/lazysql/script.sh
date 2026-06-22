#!/bin/bash

LAZYSQL_VERSION="0.5.4"

install() {
    if is_arch; then
        pkg_install lazysql
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd lazysql; then
        local current_version
        current_version=$(lazysql --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        if [[ "$current_version" == "$LAZYSQL_VERSION" ]]; then
            log_success "lazysql v$LAZYSQL_VERSION is already installed."
            return 0
        fi
        log_info "Updating lazysql from $current_version to $LAZYSQL_VERSION..."
    else
        log_info "Installing lazysql v$LAZYSQL_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    # Note: lazysql release assets omit the version from the filename
    local url="https://github.com/jorgerojas26/lazysql/releases/download/v${LAZYSQL_VERSION}/lazysql_Linux_${arch}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Downloading lazysql from $url..."
    if curl -LSs "$url" -o "$tmp_dir/lazysql.tar.gz"; then
        tar -xzf "$tmp_dir/lazysql.tar.gz" -C "$tmp_dir"
        sudo install "$tmp_dir/lazysql" /usr/local/bin/lazysql
        log_success "lazysql v$LAZYSQL_VERSION installed to /usr/local/bin/lazysql"
    else
        log_error "Failed to download lazysql."
    fi

    rm -rf "$tmp_dir"
}

configure() {
    : # no config files to symlink
}

update() {
    if is_arch; then
        pkg_update lazysql
    elif is_ubuntu; then
        install_ubuntu
    fi
}
