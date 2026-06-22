#!/bin/bash

# Git workflow scripts installed to ~/bin

install() {
    mkdir -p "$HOME/bin"
}

configure() {
    log_info "Installing global scripts to ~/bin..."

    local scripts_dir="$DIR/bin"

    for script in "$scripts_dir"/*; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            symlink_file "$script" "$HOME/bin/$(basename "$script")"
        fi
    done

    if ! grep -q '$HOME/bin' "$HOME/.bashrc"; then
        log_info "Adding ~/bin to PATH in .bashrc..."
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    log_success "Global scripts installed."
}

update() {
    configure
}
