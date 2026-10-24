#!/bin/bash

DRAWIO_VERSION="32.6.1"
DRAWIO_BASE_URL="https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}"
DRAWIO_DEB="drawio-amd64-${DRAWIO_VERSION}.deb"
DRAWIO_DEB_SHA256="515a975fbdb982e0d736b6f99248dbbb856a8b07bb72d6d3648a54b850fa33db"
DRAWIO_APPIMAGE="drawio-x86_64-${DRAWIO_VERSION}.AppImage"
DRAWIO_APPIMAGE_SHA256="b0b9f76756be5de5b93286e61713f6832956082ff22dd3ad59c2d62eb9eec932"
DRAWIO_APPIMAGE_DEST="$HOME/.local/bin/drawio"
DRAWIO_MARKER="$HOME/.local/state/drawio/installed.version"

# Download release asset $1 to $3, verifying it against sha256 $2.
drawio_download() {
    local asset=$1 sha=$2 dest=$3
    log_info "Downloading draw.io v$DRAWIO_VERSION ($asset)..."
    if ! curl -fSL "$DRAWIO_BASE_URL/$asset" -o "$dest"; then
        log_error "Failed to download $DRAWIO_BASE_URL/$asset"
        return 1
    fi
    if ! echo "$sha  $dest" | sha256sum -c --status; then
        log_error "SHA256 mismatch for $asset; refusing to install."
        return 1
    fi
}

install() {
    if is_wsl; then
        log_warn "Skipping draw.io (GUI) in WSL environment."
        return
    fi

    if [ "$(uname -m)" != "x86_64" ]; then
        log_warn "Skipping draw.io: only x86_64 builds are pinned."
        return
    fi

    if [ -f "$DRAWIO_MARKER" ] && [ "$(cat "$DRAWIO_MARKER")" = "$DRAWIO_VERSION" ]; then
        log_success "draw.io v$DRAWIO_VERSION is already installed."
        return
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    if is_ubuntu; then
        if ! { drawio_download "$DRAWIO_DEB" "$DRAWIO_DEB_SHA256" "$tmp_dir/$DRAWIO_DEB" &&
            sudo apt-get install -y "$tmp_dir/$DRAWIO_DEB"; }; then
            log_error "Failed to install draw.io."
            rm -rf "$tmp_dir"
            return 1
        fi
    elif is_arch; then
        # No official Arch package; run the AppImage from ~/.local/bin.
        pkg_install fuse2
        mkdir -p "$(dirname "$DRAWIO_APPIMAGE_DEST")"
        if ! drawio_download "$DRAWIO_APPIMAGE" "$DRAWIO_APPIMAGE_SHA256" "$tmp_dir/$DRAWIO_APPIMAGE"; then
            rm -rf "$tmp_dir"
            return 1
        fi
        install -m 755 "$tmp_dir/$DRAWIO_APPIMAGE" "$DRAWIO_APPIMAGE_DEST"
    fi

    mkdir -p "$(dirname "$DRAWIO_MARKER")"
    echo "$DRAWIO_VERSION" > "$DRAWIO_MARKER"
    log_success "draw.io v$DRAWIO_VERSION installed."
    rm -rf "$tmp_dir"
}

configure() {
    if is_wsl; then
        return
    fi

    if is_arch && [ -x "$DRAWIO_APPIMAGE_DEST" ]; then
        local desktop_dir="$HOME/.local/share/applications"
        mkdir -p "$desktop_dir"
        cat > "$desktop_dir/drawio.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=draw.io
Comment=Diagramming
Exec=$DRAWIO_APPIMAGE_DEST --no-sandbox %U
Terminal=false
Categories=Graphics;
DESKTOP
    fi
}

update() {
    install
}
