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
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local tarball="zig-${arch}-linux-${ZIG_VERSION}.tar.xz"
    local url="https://ziglang.org/download/${ZIG_VERSION}/${tarball}"

    log_info "Downloading Zig from $url..."
    curl -LSs "$url" -o "/tmp/$tarball"

    log_info "Extracting Zig to $ZIG_INSTALL_DIR..."
    sudo rm -rf "$ZIG_INSTALL_DIR"
    sudo mkdir -p "$ZIG_INSTALL_DIR"
    sudo tar -C "$ZIG_INSTALL_DIR" --strip-components=1 -xf "/tmp/$tarball"
    rm "/tmp/$tarball"

    configure
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
