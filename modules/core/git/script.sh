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
        work_dir_path="${work_git_dir/#\~/$HOME}"

        if [ ! -d "$work_dir_path" ]; then
            log_info "Creating work git directory at $work_dir_path"
            mkdir -p "$work_dir_path"
        fi

        render_template "$DIR/config/git/gitconfig.work" "$work_dir_path/.gitconfig"
    fi
}

update() {
    pkg_update git
}
