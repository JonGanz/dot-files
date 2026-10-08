#!/bin/bash
# Safety net for 10-archive-claude-md.sh: copies a task's root CLAUDE.md to
# ~/work/history/.snapshots/<ticket>.md before any worktree is torn down.
#
# Deliberately makes no decisions (no "last repo" check, no state-file parsing)
# so nothing about the ticket dir's contents can make it skip. fleet deletes
# the ticket dir after the last repo, so if the archive hook skips or fails,
# this snapshot is what survives. The archive hook removes it after a
# successful archive.

set -u

HISTORY_DIR="$HOME/work/history"
SNAPSHOT_DIR="$HISTORY_DIR/.snapshots"

ticket="${FLEET_TICKET:-}"
worktree_dir="${FLEET_WORKTREE_DIR:-}"

[ -n "$ticket" ] && [ -n "$worktree_dir" ] || exit 0

source_file="$(dirname "$worktree_dir")/CLAUDE.md"
[ -f "$source_file" ] || exit 0

if ! mkdir -p "$SNAPSHOT_DIR" || ! cp -f "$source_file" "$SNAPSHOT_DIR/$ticket.md"; then
    echo "warning: snapshot-claude-md: failed to snapshot $source_file to $SNAPSHOT_DIR/$ticket.md" >&2
fi
