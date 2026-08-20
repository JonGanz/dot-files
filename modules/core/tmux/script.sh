#!/bin/bash

HARPOON_COMMIT="76954b686a41341bd299114655e8f442d8be44a"

install() {
    pkg_install tmux
    install_harpoon
}

install_harpoon() {
    if has_cmd harpoon; then
        log_success "tmux-harpoon is already installed."
        return 0
    fi

    log_info "Installing tmux-harpoon from source..."

    mkdir -p "$HOME/.local/bin"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1

    git clone https://github.com/chaitanyabsprip/tmux-harpoon.git
    cd tmux-harpoon || exit 1
    git checkout "$HARPOON_COMMIT"

    INSTALL_PATH="$HOME/.local/bin" make install

    # Clean up
    cd "$DIR" || exit 1
    rm -rf "$tmp_dir"

    log_success "tmux-harpoon installed successfully!"
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
    rm -f "$HOME/.local/bin/harpoon"
    install_harpoon
}
