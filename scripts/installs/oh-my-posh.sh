#!/usr/bin/env bash
set -euo pipefail

: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

if ! command -v oh-my-posh >/dev/null 2>&1; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi

oh_my_posh_theme_file="$SETUP_DIR/dotfiles/ohmyposh/theme.omp.json"
ensure_block_in_file "$HOME/.bashrc" "Initialize oh-my-posh" "$(cat <<EOF
eval "\$(oh-my-posh init bash --config $oh_my_posh_theme_file)"
EOF
)"

