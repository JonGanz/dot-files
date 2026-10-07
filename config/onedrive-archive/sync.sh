#!/bin/bash

# One-way mirror of home-relative directories into a OneDrive archive folder.
# Usage: onedrive-archive-sync [--dry-run] [--force] <dest-root> <home-relative-dir>...

set -u

DELETE_LIMIT=100
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/onedrive-archive.lock"

# Never mirror anything that looks like a credential
EXCLUDES=(
    '.env'
    '.local.env'
    '*.key'
    '*.pem'
    'id_*'
    'node_modules/'
)

dry_run=false
force=false
while [[ "${1:-}" == --* ]]; do
    case "$1" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
        *) echo "[ERROR] Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [--dry-run] [--force] <dest-root> <home-relative-dir>..." >&2
    exit 2
fi

dest_root="${1%/}"
shift

# Only one run at a time; a slow sync must not stack up behind the timer
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    echo "[INFO] Another sync is running, skipping"
    exit 0
fi

# An unmounted /mnt/c or a moved OneDrive folder would otherwise be recreated as an empty tree
if [ ! -d "$(dirname "$dest_root")" ]; then
    echo "[ERROR] OneDrive folder not found: $(dirname "$dest_root")" >&2
    exit 1
fi

rsync_args=(-rt --delete --no-perms --no-owner --no-group --modify-window=2)
for pattern in "${EXCLUDES[@]}"; do
    rsync_args+=(--exclude="$pattern")
done
[ "$force" = true ] || rsync_args+=(--max-delete="$DELETE_LIMIT")
[ "$dry_run" = true ] && rsync_args+=(--dry-run --itemize-changes)

failures=0
for relative_dir in "$@"; do
    source_dir="$HOME/$relative_dir"
    target_dir="$dest_root/$relative_dir"

    # --delete against a missing or empty source would wipe the archive
    if [ -z "$(find "$source_dir" -type f -print -quit 2>/dev/null)" ]; then
        echo "[ERROR] Source missing or has no files, refusing to mirror: $source_dir" >&2
        failures=$((failures + 1))
        continue
    fi

    mkdir -p "$target_dir"
    if rsync "${rsync_args[@]}" "$source_dir/" "$target_dir/"; then
        echo "[INFO] Synced $source_dir"
    else
        echo "[ERROR] rsync failed (exit $?) for $source_dir" >&2
        failures=$((failures + 1))
    fi
done

[ "$failures" -eq 0 ]
