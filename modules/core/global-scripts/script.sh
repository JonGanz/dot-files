#!/bin/bash

# Git workflow scripts installed to ~/bin

install() {
    mkdir -p "$HOME/bin"
}

configure() {
    local scripts_dir="$DIR/bin"

    for script in "$scripts_dir"/*; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            symlink_file "$script" "$HOME/bin/$(basename "$script")"
        fi
    done

    bashrc_d_link "$DIR/config/global-scripts/bashrc.sh" global-scripts

    log_success "Global scripts installed."
}

update() {
    # Nothing to update; configure() runs automatically after update.
    :
}
