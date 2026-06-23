#!/bin/bash

install() {
    if is_arch; then
        pkg_install openssh
    elif is_ubuntu; then
        pkg_install openssh-client
    fi
}

configure() {
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Personal key — generate if not present
    # ssh-keygen handles the passphrase prompt interactively (never stored in config)
    local personal_key="$HOME/.ssh/id_ed25519_personal"
    if [ ! -f "$personal_key" ]; then
        log_step "Generating personal SSH key (you will be prompted for a passphrase)..."
        ssh-keygen -t ed25519 -C "$git_email_personal" -f "$personal_key"
        log_success "Personal key generated: $personal_key"
        log_info "Add to GitHub: $(cat "${personal_key}.pub")"
    else
        log_success "Personal SSH key already exists, skipping generation"
    fi

    # Work key — import from Windows (WSL only)
    if is_wsl && [ -n "$ssh_windows_username" ] && [ -n "$ssh_work_key_name" ]; then
        local win_key="/mnt/c/Users/$ssh_windows_username/.ssh/$ssh_work_key_name"
        local dest_key="$HOME/.ssh/$ssh_work_key_name"
        if [ ! -f "$dest_key" ]; then
            if [ -f "$win_key" ]; then
                log_step "Importing work SSH key from Windows..."
                cp "$win_key" "$dest_key"
                [ -f "${win_key}.pub" ] && cp "${win_key}.pub" "${dest_key}.pub"
                chmod 600 "$dest_key"
                [ -f "${dest_key}.pub" ] && chmod 644 "${dest_key}.pub"
                log_success "Work key imported: $dest_key"
            else
                log_warn "Work key not found at $win_key — skipping import"
            fi
        else
            log_success "Work SSH key already exists, skipping import"
        fi
    fi

    # Write SSH config — work template if work key is configured, otherwise personal
    if [ -n "$ssh_work_key_name" ]; then
        render_template "$DIR/config/ssh/config.work" "$HOME/.ssh/config"
    else
        render_template "$DIR/config/ssh/config.personal" "$HOME/.ssh/config"
    fi
    chmod 600 "$HOME/.ssh/config"
    log_success "SSH config written"
}
