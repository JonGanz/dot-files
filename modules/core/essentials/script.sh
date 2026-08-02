#!/bin/bash

# Default essentials.

install() {
    log_info "Installing essential tools..."
    local pkgs=( \
	bats \
        curl \
        dos2unix \
        ffmpeg \
        fzf \
        imagemagick \
        jq \
        less \
        ripgrep \
        sed \
        tree \
        unzip \
    )
    if is_arch; then
        pkgs+=( \
            base-devel \
        )
    elif is_ubuntu; then
        pkgs+=( \
            build-essential \
            linux-tools-common \
            linux-tools-generic \
            ncal \
            nfs-common \
            resvg \
        )
    fi
    pkg_install "${pkgs[@]}"
}

configure() {
    log_info "No specific configuration for essentials."
}

update() {
    log_info "Updating essential tools..."
    local pkgs=( \
        curl \
        ffmpeg \
        jq \
        less \
        ripgrep \
        sed \
        tree \
        unzip \
    )
    if is_arch; then
        pkgs+=( \
            base-devel \
        )
    elif is_ubuntu; then
        pkgs+=( \
            build-essential \
            linux-tools-common \
            linux-tools-generic \
            ncal \
            nfs-common \
            resvg \
        )
    fi
    pkg_update "${pkgs[@]}"
}
