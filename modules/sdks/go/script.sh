#!/bin/bash

# Golang module

GO_VERSION="1.26.2"
GO_INSTALL_DIR="/usr/local/go"

install() {
    log_info "Ensuring Go $GO_VERSION is installed..."

    if has_cmd go && go version | grep -q "go$GO_VERSION"; then
        log_success "Go $GO_VERSION is already installed."
        return 0
    fi

    log_info "Installing Go $GO_VERSION..."

    # Ensure dependencies for downloading/extracting are met
    # essentials should be run first, but let's be safe
    if ! has_cmd curl || ! has_cmd tar; then
        pkg_install curl tar
    fi

    local arch
    arch=$(get_arch go) || return 1

    local tarball="go$GO_VERSION.linux-$arch.tar.gz"
    local url="https://go.dev/dl/$tarball"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Download and verify before touching the existing install
    if ! download_file "$url" "$tmp_dir/$tarball" || ! tar -tzf "$tmp_dir/$tarball" >/dev/null; then
        log_error "Go download failed; existing install left untouched."
        rm -rf "$tmp_dir"
        return 1
    fi

    log_info "Extracting Go to $GO_INSTALL_DIR..."
    sudo rm -rf "$GO_INSTALL_DIR"
    sudo tar -C /usr/local -xzf "$tmp_dir/$tarball"
    local status=$?
    rm -rf "$tmp_dir"
    return "$status"
}

configure() {
    log_info "Configuring Go environment..."

    # Ensure /usr/local/go/bin is in the PATH for the system
    # We'll create a symlink for the go binary as it's cleaner than editing shell profiles directly
    if [ -f "$GO_INSTALL_DIR/bin/go" ]; then
        if [ ! -L "/usr/local/bin/go" ]; then
            log_info "Linking go binary to /usr/local/bin/go"
            sudo ln -s "$GO_INSTALL_DIR/bin/go" /usr/local/bin/go
        fi
        if [ ! -L "/usr/local/bin/gofmt" ]; then
            log_info "Linking gofmt binary to /usr/local/bin/gofmt"
            sudo ln -s "$GO_INSTALL_DIR/bin/gofmt" /usr/local/bin/gofmt
        fi
    fi

    bashrc_d_link "$DIR/modules/sdks/go/env.sh" go
}

update() {
    # Since we want a specific version, update is just install
    install
}
