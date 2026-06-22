#!/bin/bash

install() {
    pkg_install tmux
}

configure() {
    local src="$DIR/config/tmux/tmux.conf"
    local dest="$HOME/.tmux.conf"

    if [ -f "$src" ]; then
        symlink_file "$src" "$dest"
    else
        log_warn "tmux.conf not found at $src."
    fi
}

update() {
    pkg_update tmux
}
