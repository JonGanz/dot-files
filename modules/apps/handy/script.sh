#!/bin/bash

HANDY_VERSION="0.9.8"
HANDY_BASE_URL="https://github.com/cjpais/Handy/releases/download/v${HANDY_VERSION}"
HANDY_DEB="Handy_${HANDY_VERSION}_amd64.deb"
HANDY_DEB_SHA256="4efe1fdcc2b68e95612e866810ccb23e06bbdf004a4e857de0862b0c6927caa8"
HANDY_APPIMAGE="Handy_${HANDY_VERSION}_amd64.AppImage"
HANDY_APPIMAGE_SHA256="d683dc96762f9a47975045ab480392d33a5b491968fb336dcac47e2f65e7184f"
HANDY_APPIMAGE_DEST="$HOME/.local/bin/handy"
HANDY_MARKER="$HOME/.local/state/handy/installed.version"

# Download $1 (release asset) to $3, verifying it against sha256 $2.
handy_download() {
    local asset=$1 sha=$2 dest=$3
    log_info "Downloading Handy v$HANDY_VERSION ($asset)..."
    if ! curl -fSL "$HANDY_BASE_URL/$asset" -o "$dest"; then
        log_error "Failed to download $HANDY_BASE_URL/$asset"
        return 1
    fi
    if ! echo "$sha  $dest" | sha256sum -c --status; then
        log_error "SHA256 mismatch for $asset; refusing to install."
        return 1
    fi
}

install() {
    if is_wsl; then
        log_warn "Skipping Handy (GUI) in WSL environment."
        return
    fi

    if [ "$(uname -m)" != "x86_64" ]; then
        log_warn "Skipping Handy: only x86_64 builds are pinned."
        return
    fi

    if [ -f "$HANDY_MARKER" ] && [ "$(cat "$HANDY_MARKER")" = "$HANDY_VERSION" ]; then
        log_success "Handy v$HANDY_VERSION is already installed."
        return
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    if is_ubuntu; then
        if handy_download "$HANDY_DEB" "$HANDY_DEB_SHA256" "$tmp_dir/$HANDY_DEB" &&
            sudo apt-get install -y "$tmp_dir/$HANDY_DEB"; then
            mkdir -p "$(dirname "$HANDY_MARKER")"
            echo "$HANDY_VERSION" > "$HANDY_MARKER"
            log_success "Handy v$HANDY_VERSION installed."
        else
            log_error "Failed to install Handy."
            rm -rf "$tmp_dir"
            return 1
        fi
    elif is_arch; then
        # No official Arch package; run the AppImage from ~/.local/bin.
        pkg_install fuse2
        mkdir -p "$(dirname "$HANDY_APPIMAGE_DEST")"
        if handy_download "$HANDY_APPIMAGE" "$HANDY_APPIMAGE_SHA256" "$tmp_dir/$HANDY_APPIMAGE"; then
            install -m 755 "$tmp_dir/$HANDY_APPIMAGE" "$HANDY_APPIMAGE_DEST"
            mkdir -p "$(dirname "$HANDY_MARKER")"
            echo "$HANDY_VERSION" > "$HANDY_MARKER"
            log_success "Handy v$HANDY_VERSION installed to $HANDY_APPIMAGE_DEST."
        else
            rm -rf "$tmp_dir"
            return 1
        fi
    fi

    rm -rf "$tmp_dir"
}

configure() {
    if is_wsl; then
        return
    fi

    if is_arch && [ -x "$HANDY_APPIMAGE_DEST" ]; then
        local desktop_dir="$HOME/.local/share/applications"
        mkdir -p "$desktop_dir"
        cat > "$desktop_dir/handy.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Handy
Comment=Speech-to-text
Exec=$HANDY_APPIMAGE_DEST
Terminal=false
Categories=Utility;
DESKTOP
    fi
}

update() {
    install
}
