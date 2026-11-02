#!/bin/bash

# Zig toolchain installation

ZIG_VERSION="0.15.2"
ZIG_INSTALL_DIR="/usr/local/zig-$ZIG_VERSION"

install() {
    log_info "Ensuring Zig $ZIG_VERSION is installed..."

    if has_cmd zig && [[ "$(zig version)" == "$ZIG_VERSION" ]]; then
        log_success "Zig $ZIG_VERSION is already installed."
        return 0
    fi

    log_info "Installing Zig $ZIG_VERSION..."

    if ! has_cmd curl || ! has_cmd tar; then
        pkg_install curl tar
    fi

    local arch
    arch=$(get_arch native) || return 1

    local tarball="zig-${arch}-linux-${ZIG_VERSION}.tar.xz"
    local url="https://ziglang.org/download/${ZIG_VERSION}/${tarball}"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Download and verify before touching the existing install
    if ! download_file "$url" "$tmp_dir/$tarball" || ! tar -tf "$tmp_dir/$tarball" >/dev/null; then
        log_error "Zig download failed; existing install left untouched."
        rm -rf "$tmp_dir"
        return 1
    fi

    log_info "Extracting Zig to $ZIG_INSTALL_DIR..."
    sudo rm -rf "$ZIG_INSTALL_DIR"
    sudo mkdir -p "$ZIG_INSTALL_DIR"
    sudo tar -C "$ZIG_INSTALL_DIR" --strip-components=1 -xf "$tmp_dir/$tarball"
    local status=$?
    rm -rf "$tmp_dir"
    return "$status"
}

configure() {
    log_info "Configuring Zig environment..."

    if [ -f "$ZIG_INSTALL_DIR/zig" ]; then
        log_info "Linking zig binary to /usr/local/bin/zig"
        sudo ln -sf "$ZIG_INSTALL_DIR/zig" /usr/local/bin/zig
    fi
}

update() {
    # Since we want a specific version, update is just install
    install
}
