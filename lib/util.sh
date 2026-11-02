#!/bin/bash

# Utility functions

# Check if a command exists
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Symlink a file, creating parent directories if needed
# Usage: symlink_file <src> <dest>
symlink_file() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        log_error "Source file does not exist: $src"
        return 1
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Remove existing file or symlink
    if [ -L "$dest" ] || [ -f "$dest" ]; then
        rm "$dest"
    fi

    log_info "Linking $src to $dest"
    ln -s "$src" "$dest"
}

# Symlink a directory, creating parent directories if needed
# Usage: symlink_dir <src> <dest>
symlink_dir() {
    local src="$1"
    local dest="$2"

    if [ ! -d "$src" ]; then
        log_error "Source directory does not exist: $src"
        return 1
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Remove existing file, symlink, or directory
    if [ -L "$dest" ] || [ -e "$dest" ]; then
        rm -rf "$dest"
    fi

    log_info "Linking $src to $dest"
    ln -s "$src" "$dest"
}

# Render a template file by replacing {{ variable_name }} with its value
# Usage: render_template <src_template> <dest_file>
render_template() {
    local src="$1"
    local dest="$2"
    
    if [ ! -f "$src" ]; then
        log_error "Template file not found: $src"
        return 1
    fi
    
    log_info "Rendering template $src to $dest"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    # Start with the source content
    local content
    content=$(cat "$src")
    
    # Find all {{ key }} patterns and replace them
    # We use a temporary file to avoid issues with large content or special characters
    local tmp_file
    tmp_file=$(mktemp)
    cp "$src" "$tmp_file"
    
    # Iterate over all exported variables that match our CONFIG_ITEMS
    # This is a bit safer than trying to replace everything
    for item in "${CONFIG_ITEMS[@]}"; do
        IFS='|' read -r key desc default intents <<< "$item"
        local value="${!key}"
        
        # Escape special characters for sed
        local escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/{{[[:space:]]*$key[[:space:]]*}}/$escaped_value/g" "$tmp_file"
        else
            sed -i "s/{{[[:space:]]*$key[[:space:]]*}}/$escaped_value/g" "$tmp_file"
        fi
    done
    
    mv "$tmp_file" "$dest"
}

# ---- ~/.bashrc.d convention ------------------------------------------------
# Modules never append to ~/.bashrc directly. core/bash installs a single
# loader block that sources every ~/.bashrc.d/*.sh; each module that needs
# shell setup drops (symlinks) a file there with bashrc_d_link.

BASHRC_D="$HOME/.bashrc.d"

# Ensure a named, replaceable block exists in ~/.bashrc.
# Usage: ensure_bashrc_block <name> <content>
# The block is written between "# >>> setup:<name> >>>" and "# <<< setup:<name> <<<"
# markers; an existing block with the same name is replaced, so content can
# be updated or changed later without leaving stale lines behind.
ensure_bashrc_block() {
    local name="$1" content="$2"
    local bashrc="$HOME/.bashrc"
    local start="# >>> setup:$name >>>" end="# <<< setup:$name <<<"
    local block
    block=$(printf '%s\n%s\n%s' "$start" "$content" "$end")

    touch "$bashrc"
    if grep -qxF "$start" "$bashrc"; then
        local current
        current=$(sed -n "/^$(printf '%s' "$start" | sed 's/[][\/.*^$]/\\&/g')\$/,/^$(printf '%s' "$end" | sed 's/[][\/.*^$]/\\&/g')\$/p" "$bashrc")
        if [ "$current" = "$block" ]; then
            return 0
        fi
        log_info "Updating setup:$name block in $bashrc"
        local tmp
        tmp=$(mktemp)
        awk -v start="$start" -v end="$end" '
            $0 == start { skip = 1; next }
            $0 == end   { skip = 0; next }
            !skip
        ' "$bashrc" > "$tmp"
        # $(cat) drops trailing newlines so blank lines don't pile up on each rewrite
        printf '%s\n' "$(cat "$tmp")" > "$bashrc"
        rm -f "$tmp"
    else
        log_info "Adding setup:$name block to $bashrc"
    fi
    printf '\n%s\n' "$block" >> "$bashrc"
}

# Install the ~/.bashrc.d loader block (idempotent; called by core/bash and
# by bashrc_d_link so --only runs work without core/bash).
ensure_bashrc_loader() {
    mkdir -p "$BASHRC_D"
    ensure_bashrc_block bashrc.d \
'for f in "$HOME"/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done'
}

# Symlink a shell snippet into ~/.bashrc.d/<name>.sh
# Usage: bashrc_d_link <src> <name>
bashrc_d_link() {
    local src="$1" name="$2"
    ensure_bashrc_loader
    symlink_file "$src" "$BASHRC_D/$name.sh"
}

# Remove exact lines from ~/.bashrc (used to clean up lines that modules
# appended before the ~/.bashrc.d convention). A backup is written once to
# ~/.bashrc.bak-setup before the first modification.
# Usage: remove_bashrc_lines <line>...
remove_bashrc_lines() {
    local bashrc="$HOME/.bashrc"
    [ -f "$bashrc" ] || return 0

    local patterns
    patterns=$(mktemp)
    printf '%s\n' "$@" > "$patterns"

    if grep -qxF -f "$patterns" "$bashrc"; then
        [ -f "$bashrc.bak-setup" ] || cp "$bashrc" "$bashrc.bak-setup"
        log_info "Removing legacy setup lines from $bashrc (backup at $bashrc.bak-setup)"
        local tmp
        tmp=$(mktemp)
        grep -vxF -f "$patterns" "$bashrc" > "$tmp"
        mv "$tmp" "$bashrc"
    fi
    rm -f "$patterns"
}

# Clone a repo if it doesn't exist yet, otherwise fast-forward pull it
# Usage: clone_or_pull <repo_url> <dest_dir>
clone_or_pull() {
    local repo_url="$1"
    local dest_dir="${2/#\~/$HOME}"

    if [ -d "$dest_dir/.git" ]; then
        log_info "Updating $dest_dir..."
        if ! git -C "$dest_dir" pull --ff-only; then
            log_error "Failed to fast-forward pull $dest_dir (local changes or diverged history?)"
            return 1
        fi
    else
        log_info "Cloning $repo_url to $dest_dir..."
        mkdir -p "$(dirname "$dest_dir")"
        if ! git clone "$repo_url" "$dest_dir"; then
            log_error "Failed to clone $repo_url"
            return 1
        fi
    fi
}

# Refresh PATH and source language environments for all SDKs
# This ensures that tools installed in previous modules are available in the current subshell
refresh_envs() {
    # The setup script defines DIR, which is the root of the project
    local sdks_dir="$DIR/modules/sdks"
    
    if [ -d "$sdks_dir" ]; then
        for sdk in "$sdks_dir"/*; do
            if [ -d "$sdk" ] && [ -f "$sdk/env.sh" ]; then
                # log_info "Refreshing environment for $(basename "$sdk")..."
                source "$sdk/env.sh"
            fi
        done
    fi
}
