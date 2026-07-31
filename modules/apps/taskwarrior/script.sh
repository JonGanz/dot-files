#!/bin/bash

# Taskwarrior CLI task manager.

install() {
    log_info "Installing Taskwarrior..."
    if is_arch; then
        pkg_install task
    elif is_ubuntu; then
        pkg_install taskwarrior
    fi
}

configure() {
    log_info "Configuring Taskwarrior..."
    # Task only reads the XDG path if ~/.taskrc doesn't exist, so remove the
    # default one it creates on first run.
    if [ -e "$HOME/.taskrc" ] && [ ! -L "$HOME/.taskrc" ]; then
        rm "$HOME/.taskrc"
    fi
    symlink_file "$DIR/config/taskwarrior/taskrc" "$HOME/.config/task/taskrc"
}

update() {
    log_info "Updating Taskwarrior..."
    if is_arch; then
        pkg_update task
    elif is_ubuntu; then
        pkg_update taskwarrior
    fi
}
