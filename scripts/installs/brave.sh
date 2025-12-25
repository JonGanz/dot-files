#!/usr/bin/env bash
set -euo pipefail

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Brave install for environment without Desktop Environment"
    exit 2;
fi

if [[ $OS == "ubuntu" ]]; then

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update
    sudo apt install brave-browser

elif [[ $OS == "arch" ]]; then
    
    yay --cleanafter --answerclean A --noconfirm --needed -Sy brave-bin

fi

