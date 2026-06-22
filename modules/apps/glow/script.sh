#!/bin/bash

GLOW_VERSION="2.1.2"

install() {
    if is_arch; then
        pkg_install glow
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    if has_cmd glow; then
        local current_version
        current_version=$(glow --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        if [[ "$current_version" == "$GLOW_VERSION" ]]; then
            log_success "glow v$GLOW_VERSION is already installed."
            return 0
        fi
        log_info "Updating glow from $current_version to $GLOW_VERSION..."
    else
        log_info "Installing glow v$GLOW_VERSION..."
    fi

    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local url="https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_${arch}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Downloading glow from $url..."
    if curl -LSs "$url" -o "$tmp_dir/glow.tar.gz"; then
        tar -xzf "$tmp_dir/glow.tar.gz" -C "$tmp_dir"
        sudo install "$tmp_dir/glow_${GLOW_VERSION}_Linux_${arch}/glow" /usr/local/bin/glow
        log_success "glow v$GLOW_VERSION installed to /usr/local/bin/glow"
    else
        log_error "Failed to download glow."
    fi

    rm -rf "$tmp_dir"
}

configure() {
    : # no config files to symlink
}

update() {
    if is_arch; then
        pkg_update glow
    elif is_ubuntu; then
        install_ubuntu
    fi
}
