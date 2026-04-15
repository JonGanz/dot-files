#!/bin/bash

# Utility functions for the setup system

# Link a configuration file or directory from the repo to the target path
# Usage: link_config <repo_relative_path> <target_path>
link_config() {
    local src="$DIR/$1"
    local dest="$2"
    local dest_dir=$(dirname "$dest")

    if [ ! -e "$src" ]; then
        log_error "Source config not found: $src"
        return 1
    fi

    # Create destination parent directory if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        log_info "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # Handle existing file/link/directory
    if [ -L "$dest" ]; then
        local current_src=$(readlink -f "$dest")
        if [ "$current_src" == "$src" ]; then
            log_success "Symlink already correct: $dest -> $src"
            return 0
        fi
        log_info "Updating symlink: $dest"
        rm "$dest"
    elif [ -e "$dest" ]; then
        log_warn "Backing up existing entry: $dest to $dest.bak"
        rm -rf "$dest.bak" # Remove old backup if exists
        mv "$dest" "$dest.bak"
    fi

    log_info "Linking $dest -> $src"
    ln -s "$src" "$dest"
}
