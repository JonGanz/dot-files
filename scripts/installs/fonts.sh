#!/usr/bin/env bash
set -euo pipefail

: "${JET_BRAINS_VERSION:?JET_BRAINS_VERSION not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if [[ $OS == "ubuntu" ]]; then

    ensure_directory "$HOME/.local/share/fonts"

    # - name: Check if Jet Brains Mono Nerd Font installed
    #   ansible.builtin.shell: "ls {{ home }}/.fonts/JetBrainsMonoNerdFont*.ttf"
    #   register: jet_brains_installed
    #   ignore_errors: true

    # - name: "Install Jet Brains Mono v{{ jet_brains_version }} Nerd Font"
    #   when: jet_brains_installed is failed
    #   ansible.builtin.unarchive:
    #     src: "https://github.com/ryanoasis/nerd-fonts/releases/download/v{{ jet_brains_version }}/JetBrainsMono.zip"
    #     dest: "{{ home }}/.fonts/"
    #     remote_src: true

    fc-cache -f

    
    # -------------------------------------------------------


    # Get the latest version.
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | \grep -Po '"tag_name": *"v\K[^"]*')

    # Get the current version.
    CURRENT_VERSION=""
    if command -v lazygit >/dev/null 2>&1; then
        version_output=$(lazygit --version)
        if [[ $version_output =~ ,\ version=([0-9.]+), ]]; then
            CURRENT_VERSION="${BASH_REMATCH[1]}"
        fi
    fi

    if [[ "$CURRENT_VERSION" != "$LAZYGIT_VERSION" ]]; then
        echo "Current version '$CURRENT_VERSION' does not match '$LAZYGIT_VERSION'; updating'"
        pushd /tmp
        curl -Lo "lazygit.v$LAZYGIT_VERSION.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf "lazygit.v$LAZYGIT_VERSION.tar.gz" lazygit
        sudo install lazygit -D -t /usr/local/bin/
        popd
    else
        echo "Skipping install; current version already installed."
    fi

elif [[ $OS == "arch" ]]; then

    sudo pacman -S --noconfirm --needed ttf-jetbrains-mono-nerd

fi

