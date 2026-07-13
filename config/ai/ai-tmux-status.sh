#!/usr/bin/env bash
# ai-tmux-status.sh — display active AI session info in tmux status-right
# Called by tmux every 5 seconds. Must complete in < 1 second.

set -euo pipefail

CACHE_DIR="$HOME/.cache/ai-usage"
STALE_SECONDS=300  # 5 minutes
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get file mtime in epoch seconds (macOS + Linux compatible)
get_mtime() {
    local file="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f '%m' "$file" 2>/dev/null || echo 0
    else
        stat -c '%Y' "$file" 2>/dev/null || echo 0
    fi
}

now=$(date +%s)

# Check if a process is running by name pattern
is_process_alive() {
    pgrep -f "$1" &>/dev/null
}

# Decide if a provider is active:
#   1. Process alive + cache file exists (with any token data) → active
#   2. Process dead + cache mtime < STALE_SECONDS → active (just finished)
#   3. Otherwise → inactive
check_active() {
    local file="$1" process_pattern="$2"
    if [[ ! -f "$file" ]]; then
        echo "false"
        return
    fi
    if is_process_alive "$process_pattern"; then
        echo "true"
        return
    fi
    local mtime age
    mtime=$(get_mtime "$file")
    age=$(( now - mtime ))
    if (( age < STALE_SECONDS )); then
        echo "true"
    else
        echo "false"
    fi
}

# --- Check Claude ---
claude_file="$CACHE_DIR/claude.json"
claude_active=$(check_active "$claude_file" "claude")

# --- Build output: show ALL active providers ---
output=""

# Helper: format seconds → "3m" / "1h23m" / "2h"
fmt_duration() {
    local s=$1
    if (( s < 60 )); then
        echo "${s}s"
    elif (( s < 3600 )); then
        echo "$(( s / 60 ))m"
    else
        local h=$(( s / 3600 )) m=$(( (s % 3600) / 60 ))
        if (( m > 0 )); then echo "${h}h${m}m"; else echo "${h}h"; fi
    fi
}

format_remaining() {
    local reset="$1"
    local now remaining days hours mins

    [ -z "$reset" ] && return

    now=$(date +%s)
    remaining=$((reset - now))

    if [ "$remaining" -le 0 ]; then
        printf "0m"
        return
    fi

    days=$((remaining / 86400))
    hours=$(((remaining % 86400) / 3600))
    mins=$(((remaining % 3600) / 60))

    if [ "$days" -gt 0 ]; then
        printf "%dd%dh" "$days" "$hours"
    elif [ "$hours" -gt 0 ]; then
        printf "%dh%02dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# Helper: format token count → "9k" / "120k" / "1.2M"
fmt_tokens() {
    local t=$1
    if (( t >= 1000000 )); then
        echo "$(( t / 1000000 )).$(( (t % 1000000) / 100000 ))M"
    elif (( t >= 1000 )); then
        echo "$(( t / 1000 ))k"
    else
        echo "$t"
    fi
}

if [[ "$claude_active" == "true" ]] && command -v jq &>/dev/null; then
    ctx_pct=$(jq -r '.context_pct // 0 | floor' "$claude_file" 2>/dev/null || echo "0")
    cost=$(jq -r '.cost_usd // 0' "$claude_file" 2>/dev/null || echo "0")
    ctx_size=$(jq -r '.context_size // 0' "$claude_file" 2>/dev/null || echo "0")
    rate_5h=$(jq -r '.rate_5h_pct // -1' "$claude_file" 2>/dev/null || echo "-1")
    rate_7d=$(jq -r '.rate_7d_pct // -1' "$claude_file" 2>/dev/null || echo "-1")
    duration_ms=$(jq -r '.duration_ms // 0' "$claude_file" 2>/dev/null || echo "0")
    resets_at_5h=$(jq -r '.resets_at_5h // -1' "$claude_file" 2>/dev/null || echo "-1")
    resets_at_7d=$(jq -r '.resets_at_7d // -1' "$claude_file" 2>/dev/null || echo "-1")

    # Calculate tokens
    if (( ctx_size > 0 )); then
        used_tokens=$(( ctx_size * ctx_pct / 100 ))
    else
        used_tokens=$(( 1000000 * ctx_pct / 100 ))
    fi
    tok_fmt=$(fmt_tokens "$used_tokens")

    cost_fmt=$(printf '$%.2f' "$cost")
    dur_fmt=$(fmt_duration $(( duration_ms / 1000 )))

    # Rate limits
    rate_part=""
    if [[ "$rate_5h" != "-1" && "$rate_5h" != "null" ]]; then
        r5=$(printf '%.0f' "$rate_5h" 2>/dev/null || echo "0")
        rs5=$(format_remaining $resets_at_5h 2>/dev/null || echo "?")
        rate_part=" 5h ${r5}% #[fg=colour3]${rs5}#[fg=colour2]"
    fi
    if [[ "$rate_7d" != "-1" && "$rate_7d" != "null" ]]; then
        r7=$(printf '%.0f' "$rate_7d" 2>/dev/null || echo "0")
        rs7=$(format_remaining $resets_at_7d 2>/dev/null || echo "?")
        rate_part+=" │"
        rate_part+=" 7d ${r7}% #[fg=colour3]${rs7}#[fg=colour2]"
    fi

    output+="#[fg=#{@bg},bg=colour2,bold]◆ claude #[fg=colour2,bg=colour8,nobold]${rate_part}"
fi

echo -n "$output"
