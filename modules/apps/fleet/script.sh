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
    # repos.yaml is written by hand; only the hooks and task CLAUDE.md template are managed here.
    symlink_file "$DIR/config/fleet/task-claude.md" "$HOME/.config/fleet/task-claude.md"

    local hook
    for hook in "$DIR"/config/fleet/hooks/*/*; do
        [ -f "$hook" ] || continue
        symlink_file "$hook" "$HOME/.config/fleet/hooks/$(basename "$(dirname "$hook")")/$(basename "$hook")"
    done
}

update() {
    clone_or_pull "$REPO_URL" "$REPO_DIR"
    build
}
