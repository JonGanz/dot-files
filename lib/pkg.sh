#!/bin/bash

# Package manager abstraction

pkg_repo_update() {
    if is_arch; then
        log_info "Updating pacman repositories..."
        sudo pacman -Sy
    elif is_ubuntu; then
        log_info "Updating apt repositories..."
        sudo apt-get update
    fi
}

pkg_update() {
    if [[ $# -eq 0 ]]; then
        if is_arch; then
            sudo pacman -Syu --noconfirm
        elif is_ubuntu; then
            # Use the new shared method
            pkg_repo_update && sudo apt-get upgrade -y
        fi
    else
        if is_arch; then
            log_info "Updating packages via pacman: $*"
            sudo pacman -S --noconfirm "$@"
        elif is_ubuntu; then
            log_info "Updating packages via apt: $*"
            # We assume pkg_repo_update has been called once at the start of the run for efficiency
            sudo apt-get install -y --only-upgrade "$@"
        fi
    fi
}

pkg_install() {
    local missing_packages=()
    for package in "$@"; do
        if ! has_pkg "$package"; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        if [[ $# -eq 1 ]]; then
            log_success "$1 is already installed."
        else
            log_success "All $# packages are already installed."
        fi
        return 0
    fi

    log_info "Installing missing packages: ${missing_packages[*]}..."
    if is_arch; then
        sudo pacman -S --noconfirm "${missing_packages[@]}"
    elif is_ubuntu; then
        sudo apt-get install -y "${missing_packages[@]}"
    fi
}

flatpak_install() {
    local app_id=$1
    if ! command -v flatpak >/dev/null 2>&1; then
        log_info "Flatpak not found. Installing flatpak..."
        pkg_install flatpak
    fi
    
    if ! flatpak list --ids | grep -q "$app_id"; then
        log_info "Installing $app_id via flatpak..."
        flatpak install -y flathub "$app_id"
    else
        log_success "$app_id is already installed via flatpak."
    fi
}

# Check if a command exists
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed
has_pkg() {
    if is_arch; then
        pacman -Qi "$1" >/dev/null 2>&1
    elif is_ubuntu; then
        dpkg -s "$1" >/dev/null 2>&1
    fi
}
