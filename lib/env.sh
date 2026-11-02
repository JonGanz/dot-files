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

# Print the machine architecture in a given naming style.
# Usage: get_arch [style]
#   uname  -> x86_64 / arm64   (default; most Go-built release tarballs)
#   go     -> amd64  / arm64   (GOARCH naming)
#   native -> x86_64 / aarch64 (uname -m / Rust target triples)
get_arch() {
    local style="${1:-uname}" machine
    machine=$(uname -m)
    case "$machine:$style" in
        x86_64:go)                  echo "amd64" ;;
        x86_64:*)                   echo "x86_64" ;;
        aarch64:go|aarch64:uname)   echo "arm64" ;;
        aarch64:native)             echo "aarch64" ;;
        *) log_error "Unsupported architecture: $machine"; return 1 ;;
    esac
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
