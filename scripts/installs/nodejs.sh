#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

: "${NVM_VERSION:?NVM_VERSION not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if is_distro ubuntu; then

    if ! command -v nvm >/dev/null 2>&1; then
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh" | bash
    fi

    NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    CURR_NVM_VERSION=$(nvm --version)

    if [[ "$CURR_NVM_VERSION" != "$NVM_VERSION" ]]; then
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh" | bash
    fi

elif is_distro arch; then

    sudo pacman -S --noconfirm --needed \
        nvm

    source /usr/share/nvm/init-nvm.sh
fi


    ensure_block_in_file "$HOME/.bashrc" "NVM Bash Autocomplete" "$(cat <<EOF
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
    )"


if ! command -v node >/dev/null 2>&1; then
    nvm install --lts=krypton
    nvm use --lts
fi

