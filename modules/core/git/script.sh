#!/bin/bash

install() {
    pkg_install git
}

configure() {
    log_info "Configuring git..."
    
    local template="$DIR/config/git/gitconfig.personal"
    local dest="$HOME/.gitconfig"
    
    render_template "$template" "$dest"
    
    if [ -n "$work_git_dir" ]; then
        local work_dir_path
        # Expand ~ if it's present
        work_dir_path="${work_git_dir/#\~/$HOME}"
        
        if [ ! -d "$work_dir_path" ]; then
            log_info "Creating work git directory at $work_dir_path"
            mkdir -p "$work_dir_path"
        fi
        
        if [ ! -f "$work_dir_path/.gitconfig" ]; then
            log_info "Creating initial work .gitconfig at $work_dir_path/.gitconfig"
            touch "$work_dir_path/.gitconfig"
        fi
    fi
}

update() {
    pkg_update git
}
