#!/usr/bin/env bash
# tmux-jump-picker.sh — one fzf popup that lists everything worth jumping to:
#
#   agent    live/stale AI agents (agent-status-collector, pruned first, via
#            the same query/dedup/preview approach as tmux-asc-binder/scripts/jump.sh),
#            label prefixed with its tmux-asc-binder icon (@asc_icon_<state>,
#            same defaults/overrides as the status bar)
#   task     fleet-task worktrees (fleet-task list --json) — each ticket's OWN
#            tmux session for editing/agents/shells, created on first jump
#   runtime  the single fleet session (fleet-run's active-ticket app runner —
#            picking this never starts/stops anything, it only switches to it)
#   home     the "home" session, called out on its own
#   session  any other tmux session not already covered above
#
# Every row leads with a SESSION column ("exists" or "*new"): "exists" means
# picking the row switches to an already-running tmux session, "*new" (task
# rows only) means picking it creates one. Any source whose backing command
# is missing/erroring is skipped, not fatal — a bare `home`/`session`-only
# list on a machine with no agents/fleet tasks is a valid, working result,
# not a broken one.
set -uo pipefail

ROWS=""

# --- helpers -----------------------------------------------------------

# fleet_repos_file prints the path to fleet's repos.yaml, honoring the same
# env var overrides fleet-task/fleet-run resolve it with.
fleet_repos_file() {
	if [ -n "${FLEET_REPOS_FILE:-}" ]; then
		printf '%s' "$FLEET_REPOS_FILE"
		return
	fi
	local cfg_dir="${FLEET_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/fleet}"
	printf '%s/repos.yaml' "$cfg_dir"
}

# fleet_session_name prints repos.yaml's tmux.session_name, defaulting to
# "fleet" if the file or key is missing.
fleet_session_name() {
	local f
	f="$(fleet_repos_file)"
	if [ -f "$f" ]; then
		awk '
			/^tmux:/ { in_tmux=1; next }
			in_tmux && /^[^[:space:]]/ { in_tmux=0 }
			in_tmux && /session_name:/ {
				sub(/^[^:]*:[[:space:]]*/, "");
				gsub(/["'"'"']/, "");
				print;
				exit
			}
		' "$f"
	fi
}

# session_name_safe <ticket> <description> prints a tmux-session-name-safe
# "<ticket> <description>" — tmux session names can't contain ':' or '.', and
# newlines/tabs would break the picker's own row format.
session_name_safe() {
	local ticket="$1" desc="$2"
	printf '%s %s' "$ticket" "$desc" | tr ':.\t\n' '    ' | sed -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//'
}

# --- source: agents ------------------------------------------------------
# Same query as tmux-asc-binder/scripts/jump.sh: dedup by pane_id (keep the
# most recently started record), drop panes that no longer exist. Not
# sourcing that script directly since it drives its own fzf+switch and exits;
# this lifts its jq pipeline so agent rows can be merged with everything else.

add_agent_rows() {
	local bin
	bin="$(tmux show-options -gqv @asc_binary 2>/dev/null || true)"
	[ -n "$bin" ] || bin="$(command -v agent-status 2>/dev/null || true)"
	[ -n "$bin" ] || return 0
	command -v jq >/dev/null 2>&1 || return 0

	# clear out stale sessions first so the list below isn't cluttered with
	# agents that are long gone; best-effort, never fatal to the picker.
	"$bin" prune >/dev/null 2>&1 || true

	local list_json live_panes rows
	list_json="$("$bin" list --json --all 2>/dev/null || true)"
	[ -n "$list_json" ] || return 0

	live_panes="$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')"
	[ -n "$live_panes" ] || live_panes="[]"

	# Icon per state mirrors tmux-asc-binder/scripts/lib.sh's asc_icon (same
	# default glyphs, same @asc_icon_<state> override) -- lifted rather than
	# sourced, for the same reason as the jq pipeline above.
	local icon_active icon_done icon_blocked icon_stopped icon_unknown
	icon_active="$(tmux show-options -gqv @asc_icon_active 2>/dev/null)"
	[ -n "$icon_active" ] || icon_active='*'
	icon_done="$(tmux show-options -gqv @asc_icon_done 2>/dev/null)"
	[ -n "$icon_done" ] || icon_done='-'
	icon_blocked="$(tmux show-options -gqv @asc_icon_blocked 2>/dev/null)"
	[ -n "$icon_blocked" ] || icon_blocked='?'
	icon_stopped="$(tmux show-options -gqv @asc_icon_stopped 2>/dev/null)"
	[ -n "$icon_stopped" ] || icon_stopped='x'
	icon_unknown="$(tmux show-options -gqv @asc_icon_unknown 2>/dev/null)"
	[ -n "$icon_unknown" ] || icon_unknown='.'

	rows="$(printf '%s' "$list_json" | jq -r --argjson live_panes "$live_panes" \
	  --arg icon_active "$icon_active" --arg icon_done "$icon_done" \
	  --arg icon_blocked "$icon_blocked" --arg icon_stopped "$icon_stopped" \
	  --arg icon_unknown "$icon_unknown" '
	  {active: $icon_active, done: $icon_done, blocked: $icon_blocked, stopped: $icon_stopped, unknown: $icon_unknown} as $icons
	  | [ .[]
	    | select(.status.multiplexer.type == "tmux")
	    | select((.status.multiplexer.pane_id // "") != "")
	    | select(.status.multiplexer.pane_id as $pane_id | $live_panes | index($pane_id) != null)
	  ]
	  | group_by(.status.multiplexer.pane_id)
	  | map(max_by(.status.started_at))
	  | .[]
	  | (.status.task_summary // "") as $summary
	  | (if $summary != "" then $summary
	     else (.status.multiplexer.session + ":" + .status.multiplexer.window)
	     end) as $label
	  | (($icons[.status.state] // $icon_unknown) + " " + $label) as $labeled
	  | ["exists", "agent", $labeled, .status.state, .status.provider, .status.multiplexer.session_id, .status.multiplexer.window_id, .status.multiplexer.pane_id] | @tsv
	' 2>/dev/null || true)"

	[ -n "$rows" ] && ROWS+="$rows"$'\n'
}

# --- source: fleet tasks --------------------------------------------------
# Each ticket gets its own session, independent of the runtime session.
# Sessions this script creates are tagged with @fleet_task_id so re-running
# recognizes them without parsing the session name; sessions it didn't
# create (none should match, since the name embeds the ticket) fall back to
# a name-prefix match.

add_task_rows() {
	command -v fleet-task >/dev/null 2>&1 || return 0
	command -v jq >/dev/null 2>&1 || return 0

	local list_json rows
	list_json="$(fleet-task list --json 2>/dev/null || true)"
	[ -n "$list_json" ] || return 0

	rows="$(printf '%s' "$list_json" | jq -r '
	  .[]
	  | select(.repos | length > 0)
	  | [.ticket, .description, (.repos[0].worktree_path // "")] | @tsv
	' 2>/dev/null || true)"
	[ -n "$rows" ] || return 0

	# fleet-task lays out every repo's worktree as <worktree_root>/<ticket>/<repo>
	# (fleet/fleet-task/cmd_new.go), so the parent of any one repo's worktree_path
	# is the ticket's own root directory -- not any single repo inside it.
	while IFS=$'\t' read -r ticket desc first_repo_worktree; do
		[ -n "$ticket" ] || continue
		local name existing task_root session_status
		task_root="$(dirname -- "$first_repo_worktree")"
		name="$(session_name_safe "$ticket" "$desc")"
		existing="$(tmux list-sessions -F '#{session_name}	#{@fleet_task_id}' 2>/dev/null | awk -F'\t' -v t="$ticket" '$2 == t {print $1; exit}')"
		[ -n "$existing" ] || existing="$(tmux list-sessions -F '#{session_name}' 2>/dev/null | awk -v n="$name" '$0 == n {print; exit}')"
		# Leading "exists"/"*new" SESSION column so similar ticket/description
		# rows can still be told apart by whether picking them jumps straight
		# to an already-running session or creates a fresh one.
		if [ -n "$existing" ]; then session_status="exists"; else session_status="*new"; fi
		ROWS+="$(printf '%s\ttask\t%s %s\t%s\t%s\t%s\t%s' "$session_status" "$ticket" "$desc" "$ticket" "$task_root" "${existing:-}" "$name")"$'\n'
	done <<<"$rows"
}

# --- source: runtime / home / other sessions ------------------------------

add_session_rows() {
	local fleet_name claimed
	fleet_name="$(fleet_session_name)"
	[ -n "$fleet_name" ] || fleet_name="fleet"

	# tickets already surfaced as task rows shouldn't also show up again as
	# a generic session row if a same-named session happens to exist.
	claimed="$(printf '%s' "$ROWS" | awk -F'\t' '$2=="task" && $6!="" {print $6}')"

	while IFS= read -r sess; do
		[ -n "$sess" ] || continue
		if [ "$sess" = "$fleet_name" ]; then
			ROWS+="$(printf 'exists\truntime\t%s (running apps)' "$sess")"$'\t'"$sess"$'\n'
			continue
		fi
		if [ "$sess" = "home" ]; then
			ROWS+="$(printf 'exists\thome\t%s' "$sess")"$'\t'"$sess"$'\n'
			continue
		fi
		if printf '%s\n' "$claimed" | grep -qxF "$sess"; then
			continue
		fi
		ROWS+="$(printf 'exists\tsession\t%s' "$sess")"$'\t'"$sess"$'\n'
	done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)
}

# --- build + pick ----------------------------------------------------------

add_agent_rows
add_task_rows
add_session_rows

if [ -z "$ROWS" ]; then
	echo "tmux-jump-picker: nothing to show (no agents, tasks, or sessions found)" >&2
	exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
	echo "tmux-jump-picker: fzf not found on PATH" >&2
	exit 1
fi

SELECTED="$(printf '%s' "$ROWS" | fzf \
	--delimiter='\t' \
	--with-nth=1,2,3 \
	--header=$'SESSION\tTYPE\tLABEL' \
	--ansi)"

[ -n "$SELECTED" ] || exit 0

TYPE="$(printf '%s' "$SELECTED" | cut -f2)"

case "$TYPE" in
agent)
	SESSION_ID="$(printf '%s' "$SELECTED" | cut -f6)"
	WINDOW_ID="$(printf '%s' "$SELECTED" | cut -f7)"
	PANE_ID="$(printf '%s' "$SELECTED" | cut -f8)"
	[ -n "$SESSION_ID" ] && tmux switch-client -t "$SESSION_ID"
	[ -n "$WINDOW_ID" ] && tmux select-window -t "$WINDOW_ID"
	[ -n "$PANE_ID" ] && tmux select-pane -t "$PANE_ID"
	;;
task)
	TICKET="$(printf '%s' "$SELECTED" | cut -f4)"
	WORKTREE="$(printf '%s' "$SELECTED" | cut -f5)"
	EXISTING="$(printf '%s' "$SELECTED" | cut -f6)"
	NAME="$(printf '%s' "$SELECTED" | cut -f7)"
	if [ -n "$EXISTING" ]; then
		tmux switch-client -t "$EXISTING"
	else
		tmux new-session -d -s "$NAME" -c "$WORKTREE"
		tmux set-option -t "$NAME" @fleet_task_id "$TICKET"
		tmux switch-client -t "$NAME"
	fi
	;;
runtime | home | session)
	TARGET="$(printf '%s' "$SELECTED" | cut -f4)"
	tmux switch-client -t "$TARGET"
	;;
esac
