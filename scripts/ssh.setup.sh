#!/usr/bin/env bash
set -e

SSH_DIR="$HOME/.ssh"
KEY_NAME="id_ed25519"
PRIVATE_KEY="$SSH_DIR/$KEY_NAME"
PUBLIC_KEY="$PRIVATE_KEY.pub"
GITHUB_SSH_URL="https://github.com/settings/ssh/new"

mkdir -p "$SSH_DIR" && chmod 700 "$SSH_DIR"

if [[ ! -f "$PRIVATE_KEY" || ! -f "$PUBLIC_KEY" ]]; then
    ssh-keygen -t ed25519 -f "$PRIVATE_KEY" -C "$(whoami)@$(hostname)"

    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy < "$PUBLIC_KEY"
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard < "$PUBLIC_KEY"
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard < "$PUBLIC_KEY"
    else
        echo "Clipboard tool not found."
        echo "Here is you public key (copy it manually):"
        echo
        cat "$PUBLIC_KEY"
    fi

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$GITHUB_SSH_URL"
    else
        echo "Please open this URL manually to configure your SSH key:"
        echo "$GITHUB_SSH_URL"
    fi

    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$PRIVATE_KEY"

fi

