#!/bin/bash

REPO_URL="git@github.com:JonGanz/fleet.git"
REPO_DIR="$own_projects_dir/fleet"

install() {
    if ! has_cmd go; then
        log_error "Go is required to build fleet (sdks/go should run before this module)."
        return 1
    fi

    clone_or_pull "$REPO_URL" "$REPO_DIR"
    build
}

build() {
    if [ ! -d "$REPO_DIR" ]; then
        log_warn "fleet not cloned, skipping build."
        return 1
    fi

    log_info "Building fleet-task, fleet-run, and fleet-cache..."
    mkdir -p "$HOME/.local/bin"

    (cd "$REPO_DIR" && ./install.sh) && log_success "fleet-task, fleet-run, and fleet-cache installed to $HOME/.local/bin"
}

configure() {
    # repos.yaml is written by hand and is left alone; only the files in
    # config/fleet/ (hooks and the task CLAUDE.md template) are managed here.
    symlink_config_dir fleet "$HOME/.config/fleet"
}

update() {
    clone_or_pull "$REPO_URL" "$REPO_DIR"
    build
}
