#!/bin/bash

REPO_URL="git@github.com:JonGanz/agent-status-collector.git"
REPO_DIR="$own_projects_dir/agent-status-collector"

install() {
    if ! has_cmd go; then
        log_error "Go is required to build agent-status-collector (sdks/go should run before this module)."
        return 1
    fi

    clone_or_pull "$REPO_URL" "$REPO_DIR"
    build
}

build() {
    if [ ! -d "$REPO_DIR" ]; then
        log_warn "agent-status-collector not cloned, skipping build."
        return 1
    fi

    log_info "Building agent-status-collector..."
    mkdir -p "$HOME/.local/bin"

    (cd "$REPO_DIR" && ./install.sh) && log_success "agent-status installed to $HOME/.local/bin/agent-status"
}

configure() {
    if ! has_cmd agent-status; then
        log_warn "agent-status not on PATH, skipping Claude Code integration setup."
        return 0
    fi

    log_info "Wiring up Claude Code integration (safe/idempotent, backs up settings.json first)..."
    agent-status setup claudecode
}

update() {
    clone_or_pull "$REPO_URL" "$REPO_DIR"
    build
    configure
}
