#!/bin/bash

LAZYDOCKER_VERSION="0.25.2"

install() {
    if is_arch; then
        pkg_install lazydocker
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd lazydocker; then
        local current_version
        current_version=$(lazydocker --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        if [[ "$current_version" == "$LAZYDOCKER_VERSION" ]]; then
            log_success "lazydocker v$LAZYDOCKER_VERSION is already installed."
            return 0
        fi
        log_info "Updating lazydocker from $current_version to $LAZYDOCKER_VERSION..."
    else
        log_info "Installing lazydocker v$LAZYDOCKER_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local url="https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_${arch}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Downloading lazydocker from $url..."
    if curl -LSs "$url" -o "$tmp_dir/lazydocker.tar.gz"; then
        tar -xzf "$tmp_dir/lazydocker.tar.gz" -C "$tmp_dir"
        sudo install "$tmp_dir/lazydocker" /usr/local/bin/lazydocker
        log_success "lazydocker v$LAZYDOCKER_VERSION installed to /usr/local/bin/lazydocker"
    else
        log_error "Failed to download lazydocker."
    fi

    rm -rf "$tmp_dir"
}

configure() {
    : # no config files to symlink
}

update() {
    if is_arch; then
        pkg_update lazydocker
    elif is_ubuntu; then
        install_ubuntu
    fi
}
