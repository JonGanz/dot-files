#!/bin/bash

# Utility functions for the setup system

# Link a configuration file from the repo to the target path
# Usage: link_config <repo_relative_path> <target_path>
link_config() {
    local src="$DIR/$1"
    local dest="$2"
    local dest_dir=$(dirname "$dest")

    if [ ! -f "$src" ]; then
        log_error "Source config file not found: $src"
        return 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        log_info "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # Handle existing file/link
    if [ -L "$dest" ]; then
        local current_src=$(readlink -f "$dest")
        if [ "$current_src" == "$src" ]; then
            log_success "Symlink already correct: $dest -> $src"
            return 0
        fi
        log_info "Updating symlink: $dest"
        rm "$dest"
    elif [ -f "$dest" ]; then
        log_warn "Backing up existing file: $dest to $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    log_info "Linking $dest -> $src"
    ln -s "$src" "$dest"
}
