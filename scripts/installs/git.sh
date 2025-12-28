#!/usr/bin/env bash
set -euo pipefail

: "${GIT_USERNAME:?GIT_USERNAME not set}"
: "${GIT_EMAIL:?GIT_EMAIL not set}"
: "${WORK_GIT_DIR:?WORK_GIT_DIR not set}"

if [[ ! -f "$HOME/.gitconfig" ]]; then
    sed \
        -e "s/{{ git_username_personal }}/$GIT_USERNAME/g;" \
        -e "s/{{ git_email_personal }}/$GIT_EMAIL/g;" \
        -e "s|{{ work_git_dir }}|$WORK_GIT_DIR|g;" \
        ./dotfiles/git/gitconfig.personal > "$HOME/.gitconfig"
else
    echo "$HOME/.gitconfig already exists; skipping generation"
fi

