#!/bin/bash
# Seeds @tw_active_task / @tw_active_task_2 from taskwarrior's currently-active
# (+ACTIVE) tasks, sorted by start time descending so the most-recently-started
# task is always primary -- matches the prior single-slot behavior, where
# starting a task always became the one shown. Called both by tmux startup
# (run-shell, since taskwarrior's hook never fires on server restart) and by
# the on-modify hook (on every start/stop), so this is the single source of
# truth for "what's active right now" instead of two mechanisms that could
# disagree (as they did before this script existed).

command -v task >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

mapfile -t descriptions < <(task rc.verbose=nothing +ACTIVE export 2>/dev/null \
    | jq -r 'sort_by(.start) | reverse | .[0:2][].description')

if [ -n "${descriptions[0]:-}" ]; then
    tmux set-option -g @tw_active_task "${descriptions[0]}"
else
    tmux set-option -gu @tw_active_task
fi

if [ -n "${descriptions[1]:-}" ]; then
    tmux set-option -g @tw_active_task_2 "${descriptions[1]}"
else
    tmux set-option -gu @tw_active_task_2
fi

exit 0
