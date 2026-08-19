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
    case $(uname -m) in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local tarball="go$GO_VERSION.linux-$arch.tar.gz"
    local url="https://go.dev/dl/$tarball"

    log_info "Downloading Go from $url..."
    curl -L "$url" -o "/tmp/$tarball"

    log_info "Extracting Go to $GO_INSTALL_DIR..."
    sudo rm -rf "$GO_INSTALL_DIR"
    sudo tar -C /usr/local -xzf "/tmp/$tarball"
    rm "/tmp/$tarball"

    # Add to PATH if not already there
    # This might need to be part of configure() or handled via profile scripts
    configure
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

    # Add Go binary paths to .bashrc for future sessions
    if ! grep -q "go/bin" "$HOME/.bashrc"; then
        log_info "Adding Go paths to .bashrc..."
        {
            echo 'export PATH="$PATH:/usr/local/go/bin"'
            echo 'export PATH="$PATH:${GOPATH:-$HOME/go}/bin"'
        } >> "$HOME/.bashrc"
    fi
}

update() {
    # Since we want a specific version, update is just install
    install
}
