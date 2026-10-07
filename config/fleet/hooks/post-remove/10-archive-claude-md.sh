#!/bin/bash
# Archives a task's root CLAUDE.md to ~/work/history/<number>-<description>.md
# once the task's last repo worktree has been removed.
#
# Only tickets shaped like <letters>-<digits> (e.g. PROJ-1234) are archived;
# anything else (bare numbers, odd ids) is left alone.
#
# fleet runs post-remove once per repo (also from `fleet-task edit`), so the
# archive only happens when no other repo worktree remains in the ticket dir.

set -u

HISTORY_DIR="$HOME/work/history"
STATE_DIR="${FLEET_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/fleet}"

ticket="${FLEET_TICKET:-}"
repo="${FLEET_REPO:-}"
worktree_dir="${FLEET_WORKTREE_DIR:-}"

[[ "$ticket" =~ ^[A-Za-z]+-([0-9]+)$ ]] || exit 0
ticket_number="${BASH_REMATCH[1]}"

[ -n "$worktree_dir" ] || exit 0
ticket_dir="$(dirname "$worktree_dir")"
source_file="$ticket_dir/CLAUDE.md"
[ -f "$source_file" ] || exit 0

# Other repos still present means the task isn't fully deleted yet.
if [ -n "$(find "$ticket_dir" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) ! -name "$repo" -print -quit)" ]; then
    exit 0
fi

# The state file is deleted only after every repo is removed, so it is still here.
state_file="$STATE_DIR/tasks/$ticket.json"
description="$(jq -r '.description // empty' "$state_file" 2>/dev/null)"
slug="$(printf '%s' "$description" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
if [ -z "$slug" ]; then
    echo "warning: archive-claude-md: no description for $ticket in $state_file; not archiving" >&2
    exit 0
fi

mkdir -p "$HISTORY_DIR" || exit 0
destination="$HISTORY_DIR/$ticket_number-$slug.md"

# Never clobber an earlier archive.
if [ -e "$destination" ]; then
    destination="$HISTORY_DIR/$ticket_number-$slug-$(date +%Y%m%d%H%M%S).md"
fi

if mv "$source_file" "$destination"; then
    echo "archived $source_file to $destination"
else
    echo "warning: archive-claude-md: failed to move $source_file to $destination" >&2
fi
