#!/usr/bin/env bash
set -euo pipefail

: "${GIT_USERNAME:?GIT_USERNAME not set}"
: "${GIT_EMAIL:?GIT_EMAIL not set}"
: "${WORK_GIT_DIR:?WORK_GIT_DIR not set}"

if [[ ! -f "$HOME/.gitconfig" ]]; then
    sed \
        "s/{{ git_username_personal }}/$GIT_USERNAME/g;
         s/{{ git_email_personal }}/$GIT_EMAIL/g;
         s/{{ work_git_dir }}/$WORK_GIT_DIR/g;" \
        ./dotfiles/git/gitconfig.personal > "$HOME/.gitconfig"
fi

