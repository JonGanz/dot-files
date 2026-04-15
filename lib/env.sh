#!/bin/bash

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_ID_LIKE=$ID_LIKE
else
    OS_ID=$(uname -s)
fi

is_arch() {
    [[ "$OS_ID" == "arch" ]] || [[ "$OS_ID_LIKE" == *"arch"* ]]
}

is_ubuntu() {
    [[ "$OS_ID" == "ubuntu" ]] || [[ "$OS_ID_LIKE" == *"ubuntu"* ]] || [[ "$OS_ID_LIKE" == *"debian"* ]]
}

# Detect WSL
is_wsl() {
    if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi "microsoft" /proc/version 2>/dev/null; then
        return 0
    fi
    return 1
}

get_os_info() {
    if is_arch; then
        echo "Arch Linux"
    elif is_ubuntu; then
        echo "Ubuntu-based"
    else
        echo "Unknown ($OS_ID)"
    fi
}

detect_env() {
    log_info "Detecting environment..."
    log_info "OS: $(get_os_info)"
    if is_wsl; then
        log_info "Environment: WSL2"
    else
        log_info "Environment: Native Linux"
    fi
}
