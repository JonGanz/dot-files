#!/bin/bash

# Taskwarrior CLI task manager.

install() {
    log_info "Installing Taskwarrior and Timewarrior..."
    if is_arch; then
        pkg_install task timew
    elif is_ubuntu; then
        pkg_install taskwarrior timewarrior
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
    symlink_file "$DIR/config/taskwarrior/hooks/on-modify-tmux-status" "$HOME/.config/task/hooks/on-modify-tmux-status"
    symlink_file "$DIR/config/taskwarrior/hooks/on-modify-timewarrior" "$HOME/.config/task/hooks/on-modify-timewarrior"
    symlink_file "$DIR/config/taskwarrior/scripts/timew-projects" "$HOME/.local/bin/timew-projects"
    symlink_file "$DIR/config/taskwarrior/scripts/timew-active-sync" "$HOME/.local/bin/timew-active-sync"
}

update() {
    log_info "Updating Taskwarrior and Timewarrior..."
    if is_arch; then
        pkg_update task timew
    elif is_ubuntu; then
        pkg_update taskwarrior timewarrior
    fi
}
