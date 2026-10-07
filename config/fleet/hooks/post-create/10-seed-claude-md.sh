#!/bin/bash
# Seeds the task root (<worktree_root>/<ticket>/) with CLAUDE.md from
# ~/.config/fleet/task-claude.md.
#
# fleet runs post-create once per repo; the file is only written if absent so
# later repos (and `fleet-task edit` additions) never clobber a CLAUDE.md that
# has since been updated with task status.

set -u

CONFIG_DIR="${FLEET_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/fleet}"
template="$CONFIG_DIR/task-claude.md"

[ -n "${FLEET_WORKTREE_DIR:-}" ] || exit 0
[ -f "$template" ] || exit 0

destination="$(dirname "$FLEET_WORKTREE_DIR")/CLAUDE.md"
[ -e "$destination" ] && exit 0

if cp "$template" "$destination"; then
    echo "seeded $destination"
else
    echo "warning: seed-claude-md: failed to copy $template to $destination" >&2
fi
