#!/bin/bash

# Required: Installation logic
install() {
    curl -fsSL https://claude.ai/install.sh | bash
}

# Optional: Configuration logic
configure() {
    log_info "Configuring my-app..."

    symlink_file "$DIR/config/ai/master.prompt" "$HOME/.claude/CLAUDE.md"
}

update() {
}

