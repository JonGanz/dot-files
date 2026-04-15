#!/bin/bash

install() {
    pkg_install tmux
}

configure() {
    # Symlink config from the organized config directory
    if [ -f "$DIR/config/tmux/tmux.conf" ]; then
        link_config "config/tmux/tmux.conf" "$HOME/.tmux.conf"
    else
        log_warn "tmux.conf not found at config/tmux/tmux.conf."
    fi
}

update() {
    pkg_update tmux
}
