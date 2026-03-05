#!/usr/bin/env bash
set -uo pipefail

source "$SETUP_DIR/bash/ensure.sh"

# Install Klassy

# TODO: Check if we actually need to install Klassy
echo 'deb http://download.opensuse.org/repositories/home:/paulmcauley/xUbuntu_25.10/ /' \
    | sudo tee /etc/apt/sources.list.d/home:paulmcauley.list
curl -fsSL https://download.opensuse.org/repositories/home:paulmcauley/xUbuntu_25.10/Release.key \
    | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/home_paulmcauley.gpg > /dev/null
sudo apt update
sudo apt install klassy

kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'library' 'org.kde.klassy'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'theme' 'klassy'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'BorderSize' 'None'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'BorderSizeAuto' 'false'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'ButtonsOnLeft' 'MFS'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'ButtonsOnRight' 'HIAX'

ensure_symlink_file "$SETUP_DIR/dotfiles/klassy/klassyrc" "$HOME/.config/klassy/klassrc"

# General KDE settings

kwriteconfig6 --file kwinrc --group 'Xwayland' --key 'Scale' '1.5'

# Install Krohnkite

if kpackagetool6 --type=KWin/Script --show krohnkite >/dev/null 2>&1; then
    echo "Krohnkite already installed"
else
    echo "Installing Krohnkite KWin script"
    # TODO: Download to a temp file, and get the path
    KROHNKITE_PATH='/home/jon/Downloads/krohnkite-0.9.9.2-1d7fd74.kwinscript'
    # https://codeberg.org/anametologin/Krohnkite/releases/download/0.9.9.2/krohnkite-0.9.9.2-1d7fd74.kwinscript
    kpackagetool6 --type=KWin/Script -i "$KROHNKITE_PATH"
fi

echo "Enabling Krohnkite KWin script"
kwriteconfig6 --file 'kwinrc' --group 'Plugins' --key 'krohnkiteEnabled' 'true'

echo "Setting Krohnkite configuration"
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'binaryTreeLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'cascadeLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'columnsLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'floatingLayoutOrder' '3'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'krohnkiteEnabled' 'true'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'limitTileWidthRatio' '1.8'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'quarterLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'screenGapBetween' '10'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'screenGapBottom' '13'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'screenGapLeft' '10'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'screenGapRight' '10'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'screenGapTop' '10'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'spiralLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'spreadLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'stackedLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'stairLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'threeColumnLayoutOrder' '0'
kwriteconfig6 --file 'kwinrc' --group 'Script-krohnkite' --key 'tileLayoutInitialRotationAngle' '2'

# Install Fluid Tile

# if [ ! -d "$OPEN_SOURCE_DIR/fluid-tile" ]; then
#     echo "Cloning fluid-tile repository to $OPEN_SOURCE_DIR/fluid-tile"
#     git clone \
#         https://codeberg.org/Serroda/fluid-tile.git \
#         --depth 1 \
#         "$OPEN_SOURCE_DIR/fluid-tile"
# else
#     echo "fluid-tile repository found at $OPEN_SOURCE_DIR/fluid-tile; fetching updates"
#     pushd "$OPEN_SOURCE_DIR/fluid-tile"
#     git fetch --prune
#     popd
# fi
#
# if kpackagetool6 --type=KWin/Script --show fluid-tile >/dev/null 2>&1; then
#     echo "Fluid Tile already installed"
# else
#     echo "Installing Fluid Tile KWin script"
#     kpackagetool6 --type=KWin/Script -i "$OPEN_SOURCE_DIR/fluid-tile"
# fi
#
# echo "Enabling Fluid Tile KWin script"
# kwriteconfig6 --file kwinrc --group Plugins --key fluid-tileEnabled true

# TabBox configuration
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName thumbnail_grid
kwriteconfig6 --file kwinrc --group TabBox --key HighlightWindows false

# Global keyboard shortcuts

## Remove keybinds I don't want/need.
kwriteconfig6 --file kglobalshortcutsrc --group 'KDE Keyboard Layout Switcher' --key 'Switch to Last-Used Keyboard Layout' 'none,none,Switch to Last-Used Keyboard Layout'
kwriteconfig6 --file kglobalshortcutsrc --group 'KDE Keyboard Layout Switcher' --key 'Switch to Next Keyboard Layout' 'none,none,Switch to Next Keyboard Layout'

## New bindings.
kwriteconfig6 --file kglobalshortcutsrc --group 'kwin' --key 'Kill Window' 'none,none,Kill Window'
kwriteconfig6 --file kglobalshortcutsrc --group 'kwin' --key 'Window Close' 'Meta+W,Alt+F4,Close Window'

