#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping CAD install for environment without Desktop Environment"
    exit 2;
fi

: "${APPIMAGE_DIR:?APPIMAGE_DIR not set}"
: "${FREECAD_VER:?FREECAD_VER not set}"

if is_distro ubuntu; then

    APPIMAGE_NAME="FreeCAD-${FREECAD_VER}.AppImage"
    APPIMAGE_PATH="$APPIMAGE_DIR/$APPIMAGE_NAME"
    DESKTOP_FILE="/usr/share/applications/freecad.desktop"
    FREECAD_BIN="/usr/local/bin/freecad"
    ICON_PATH="/usr/share/pixmaps/freecad.png"
    ICON_URL="https://github.com/FreeCAD/FreeCAD/raw/refs/heads/main/src/Gui/Icons/freecad-icon-64.png"

    if [[ ! -f "$APPIMAGE_PATH" ]]; then
      wget -O "$APPIMAGE_PATH" \
        "https://github.com/FreeCAD/FreeCAD/releases/download/${FREECAD_VER}/FreeCAD_${FREECAD_VER}-conda-Linux-x86_64-py311.AppImage"
    fi

    sudo install -m 755 "$APPIMAGE_PATH" "$FREECAD_BIN"

    sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=FreeCAD
Comment=Your own 3D parametric modeler
Exec=$FREECAD_BIN
Icon=freecad
Terminal=false
Categories=System;
StartupWMClass=freecad
EOF

    sudo chmod 644 "$DESKTOP_FILE"

    if [[ ! -f "$ICON_PATH" ]]; then
        echo "Downloading icon for FreeCAD"
        sudo curl -fsSL "$ICON_URL" -o "$ICON_PATH"
        sudo chmod 644 "$ICON_PATH"
    fi

    sudo apt-get install -y openscad

elif is_distro arch; then

    sudo pacman -S --no-confirm --needed \
        freecad \
        openscad

fi

