#!/bin/bash

# Required: Installation logic
install() {
    curl -fsSL https://claude.ai/install.sh | bash
}

# Optional: Configuration logic
configure() {
    log_info "Configuring claude CLI..."

    symlink_file "$DIR/config/ai/master.prompt" "$HOME/.claude/CLAUDE.md"
    symlink_file "$DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
    symlink_dir "$DIR/config/claude/skills" "$HOME/.claude/skills"
}

