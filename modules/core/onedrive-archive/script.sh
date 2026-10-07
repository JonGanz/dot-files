#!/bin/bash

# Mirrors selected WSL directories into the work OneDrive folder (WSL2 + work intent only).
# A systemd user timer runs config/onedrive-archive/sync.sh; on first setup, directories
# missing locally are restored from the existing archive.

CONFIG_REQUIRES=(onedrive_work_dir)

ARCHIVE_DIRS=(
    "$HOME/docs"
    "$HOME/work/history"
)

SYNC_BIN="$HOME/.local/bin/onedrive-archive-sync"
UNIT_DIR="$HOME/.config/systemd/user"

install() {
    if ! is_wsl; then
        log_info "Not running in WSL, skipping onedrive-archive"
        return 0
    fi

    has_cmd rsync || pkg_install rsync
    has_cmd flock || log_warn "flock not found (util-linux); the sync script needs it"
}

configure() {
    is_wsl || return 0

    local archive_root="${onedrive_work_dir%/}/WSL-Archive"

    if [ ! -d "$onedrive_work_dir" ]; then
        log_error "OneDrive folder not found: $onedrive_work_dir"
        log_info "Candidates: $(ls -d /mnt/c/Users/*/OneDrive\ -\ * 2>/dev/null | tr '\n' ';')"
        return 1
    fi

    # Restore before the timer exists so a fresh machine never mirrors an empty tree over the archive
    restore_missing_dirs "$archive_root" || return 1

    symlink_file "$DIR/config/onedrive-archive/sync.sh" "$SYNC_BIN"
    chmod +x "$DIR/config/onedrive-archive/sync.sh"

    write_units "$archive_root"
    enable_timer
}

update() {
    configure
}

enable_linger() {
    if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" = "yes" ]; then
        return 0
    fi

    # Keeps the user systemd instance (and so the timer) alive without an open session
    sudo loginctl enable-linger "$USER" || log_warn "Could not enable linger; the timer only runs while a WSL session is open"
}

enable_timer() {
    if ! has_cmd systemctl || ! systemctl --user show-environment >/dev/null 2>&1; then
        log_warn "systemd user instance unavailable (is systemd=true in /etc/wsl.conf?), timer not enabled"
        return 0
    fi

    systemctl --user daemon-reload
    systemctl --user enable --now onedrive-archive.timer || return 1
    enable_linger

    # Initial sync; the timer takes over from here
    systemctl --user start --no-block onedrive-archive.service
    log_success "onedrive-archive timer enabled (every 10 minutes)"
}

restore_missing_dirs() {
    local archive_root="$1"
    local dir relative_dir

    for dir in "${ARCHIVE_DIRS[@]}"; do
        relative_dir="${dir#"$HOME"/}"

        if [ -d "$dir" ]; then
            log_info "$dir exists, no restore needed"
        elif [ -d "$archive_root/$relative_dir" ]; then
            log_step "Restoring $dir from $archive_root/$relative_dir"
            mkdir -p "$dir"
            # No --delete: restoring must never remove anything locally
            rsync -rt --no-perms --no-owner --no-group "$archive_root/$relative_dir/" "$dir/" || {
                log_error "Restore failed for $dir"
                return 1
            }
        else
            log_info "$dir missing locally and no archive found, creating empty directory"
            mkdir -p "$dir"
        fi
    done
}

write_units() {
    local archive_root="$1"
    local relative_dirs=()
    local dir

    for dir in "${ARCHIVE_DIRS[@]}"; do
        relative_dirs+=("${dir#"$HOME"/}")
    done

    # '%' is a systemd specifier character and must be doubled
    local exec_dest="${archive_root//%/%%}"

    mkdir -p "$UNIT_DIR"

    cat > "$UNIT_DIR/onedrive-archive.service" <<EOF
[Unit]
Description=Mirror WSL directories to the work OneDrive folder

[Service]
Type=oneshot
ExecStart=%h/.local/bin/onedrive-archive-sync "$exec_dest" ${relative_dirs[*]}
EOF

    cat > "$UNIT_DIR/onedrive-archive.timer" <<EOF
[Unit]
Description=Mirror WSL directories to the work OneDrive folder every 10 minutes

[Timer]
OnCalendar=*:0/10
Persistent=true

[Install]
WantedBy=timers.target
EOF

    log_success "Wrote systemd units to $UNIT_DIR"
}
