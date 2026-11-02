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
            # Never -Sy here: a full -Syu already ran at the start of an --update
            # run, so a plain -S --needed is safe and avoids a partial upgrade.
            log_info "Updating packages via pacman: $*"
            sudo pacman -S --needed --noconfirm "$@"
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

# Download a URL to a file, failing loudly on any error (including HTTP errors).
# Usage: download_file <url> <dest>
download_file() {
    local url="$1" dest="$2"
    log_info "Downloading $url..."
    if ! curl -fLSs --retry 3 "$url" -o "$dest"; then
        log_error "Failed to download $url"
        return 1
    fi
}

# Install a single binary from a GitHub release (or any URL) into RELEASE_BIN_DIR
# (default /usr/local/bin), skipping when the installed version already matches.
#
# Usage: install_github_release <name> <version> <url_template> [path_in_archive] [version_cmd]
#   url_template  may contain {version}, {arch} (x86_64/arm64), {arch_go}
#                 (amd64/arm64) and {arch_native} (x86_64/aarch64).
#   path_in_archive  path of the binary inside the archive. Defaults to <name>.
#                 Ignored when the URL is a bare binary (not .tar.gz/.tgz/.zip).
#   version_cmd   command printing the installed version. Defaults to
#                 "<name> --version". The first X.Y.Z in its output is used.
install_github_release() {
    local name="$1" version="$2" url_template="$3"
    local path_in_archive="${4:-$1}" version_cmd="${5:-$1 --version}"
    local bin_dir="${RELEASE_BIN_DIR:-/usr/local/bin}"

    if has_cmd "$name"; then
        local current
        current=$($version_cmd 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        if [[ "$current" == "$version" ]]; then
            log_success "$name v$version is already installed."
            return 0
        fi
        log_info "Updating $name from ${current:-unknown} to $version..."
    else
        log_info "Installing $name v$version..."
    fi

    local arch arch_go arch_native
    arch=$(get_arch uname) || return 1
    arch_go=$(get_arch go) || return 1
    arch_native=$(get_arch native) || return 1

    local url="$url_template"
    url="${url//\{version\}/$version}"
    url="${url//\{arch\}/$arch}"
    url="${url//\{arch_go\}/$arch_go}"
    url="${url//\{arch_native\}/$arch_native}"

    local tmp_dir binary
    tmp_dir=$(mktemp -d)

    local status=0
    case "$url" in
        *.tar.gz|*.tgz)
            download_file "$url" "$tmp_dir/archive.tar.gz" \
                && tar -xzf "$tmp_dir/archive.tar.gz" -C "$tmp_dir" || status=1
            binary="$tmp_dir/$path_in_archive"
            ;;
        *.zip)
            download_file "$url" "$tmp_dir/archive.zip" \
                && unzip -oq "$tmp_dir/archive.zip" -d "$tmp_dir" || status=1
            binary="$tmp_dir/$path_in_archive"
            ;;
        *)
            download_file "$url" "$tmp_dir/$name" || status=1
            binary="$tmp_dir/$name"
            ;;
    esac

    if [[ $status -eq 0 && ! -f "$binary" ]]; then
        log_error "$path_in_archive not found in downloaded release of $name."
        status=1
    fi

    if [[ $status -eq 0 ]]; then
        local sudo_cmd=""
        [ -w "$bin_dir" ] || sudo_cmd="sudo"
        if $sudo_cmd install -m 755 "$binary" "$bin_dir/$name"; then
            log_success "$name v$version installed to $bin_dir/$name"
        else
            log_error "Failed to install $name to $bin_dir/$name"
            status=1
        fi
    fi

    rm -rf "$tmp_dir"
    return "$status"
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
