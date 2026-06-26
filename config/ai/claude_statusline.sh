#!/bin/bash
# Claude Code statusLine command — ANSI 16-color (theme-aware)

input=$(cat)

# Extract fields via jq
_jq() {
    printf '%s' "$input" | jq -r "$1 // empty"
}

# --- Colors (ANSI 16 — theme-aware) ---
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

YELLOW='\033[93m'
CYAN='\033[96m'
MAGENTA='\033[95m'
GRAY_DIM='\033[2;37m'

CTX_GREEN='\033[92m'
CTX_YELLOW='\033[93m'
CTX_ORANGE='\033[33m'
CTX_RED='\033[91m'

VEL_GREEN='\033[92m'
VEL_RED='\033[91m'

LINK_GRAY='\033[90m'

PIPE="${DIM}${GRAY_DIM} | ${RESET}"

segments=()

# --- Repo name (bold yellow) ---
repo=$(_jq '.workspace.repo.name')
if [ -n "$repo" ]; then
    segments+=("${BOLD}${YELLOW}${repo}${RESET}")
else
    cwd_display=$(_jq '.workspace.current_dir')
    [ -n "$cwd_display" ] && segments+=("${BOLD}${YELLOW}${cwd_display}${RESET}")
fi

# --- Git branch (bold cyan, leaf icon) ---
cwd=$(_jq '.workspace.current_dir')
if [ -n "$cwd" ]; then
    branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
fi
if [ -n "$branch" ]; then
    segments+=("${BOLD}${CYAN}🌿 ${branch}${RESET}")
fi

# --- Context usage: dynamic emoji + colored percentage ---
used_pct=$(_jq '.context_window.used_percentage')
used_pct="${used_pct:-0}"
used_int=$(printf '%.0f' "$used_pct")
if [ "$used_int" -lt 20 ]; then
    ctx_emoji="🟢"; ctx_color="$CTX_GREEN"
elif [ "$used_int" -lt 70 ]; then
    ctx_emoji="🟡"; ctx_color="$CTX_YELLOW"
elif [ "$used_int" -lt 90 ]; then
    ctx_emoji="🟠"; ctx_color="$CTX_ORANGE"
else
    ctx_emoji="🔴"; ctx_color="$CTX_RED"
fi
segments+=("${ctx_emoji} ${ctx_color}${used_int}%${RESET}")

# --- Rate limit usage: 5-hour session and 7-day weekly (yellow, only present for subscribers) ---
five_hr=$(_jq '.rate_limits.five_hour.used_percentage')
seven_day=$(_jq '.rate_limits.seven_day.used_percentage')
if [ -n "$five_hr" ] || [ -n "$seven_day" ]; then
    limits_seg=""
    if [ -n "$five_hr" ]; then
        five_hr_int=$(printf '%.0f' "$five_hr")
        limits_seg="${YELLOW}5h ${five_hr_int}%${RESET}"
    fi
    if [ -n "$seven_day" ]; then
        seven_day_int=$(printf '%.0f' "$seven_day")
        [ -n "$limits_seg" ] && limits_seg="${limits_seg} "
        limits_seg="${limits_seg}${YELLOW}7d ${seven_day_int}%${RESET}"
    fi
    segments+=("$limits_seg")
fi

# --- Code velocity: +lines green / -lines red ---
lines_added=$(_jq '.cost.total_lines_added')
lines_removed=$(_jq '.cost.total_lines_removed')
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
    added_val="${lines_added:-0}"
    removed_val="${lines_removed:-0}"
    velocity="${VEL_GREEN}+${added_val}${RESET}${GRAY_DIM}/${RESET}${VEL_RED}-${removed_val}${RESET}"
    segments+=("$velocity")
fi

# --- Model name + effort level (magenta, robot icon) ---
model=$(_jq '.model.display_name')
if [ -n "$model" ]; then
    effort=$(_jq '.effort.level')
    if [ -n "$effort" ]; then
        segments+=("${MAGENTA}🤖 ${model} [${effort}]${RESET}")
    else
        segments+=("${MAGENTA}🤖 ${model}${RESET}")
    fi
fi

# --- Join with dim-gray pipe separators ---
result=""
for i in "${!segments[@]}"; do
    if [ $i -gt 0 ]; then
        result="${result}${PIPE}"
    fi
    result="${result}${segments[$i]}"
done

printf '%b' "$result"
 
