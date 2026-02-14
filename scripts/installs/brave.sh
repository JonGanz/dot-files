#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Brave install for environment without Desktop Environment"
    exit 2;
fi

if is_distro ubuntu; then

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update
    sudo apt install -y brave-browser

elif is_distro arch; then
    
    yay --cleanafter --answerclean A --noconfirm --needed -Sy brave-bin

fi

