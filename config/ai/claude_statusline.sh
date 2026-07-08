#!/bin/bash
# Claude Code statusLine command — ANSI 16-color (theme-aware)

input=$(cat)

# Extract fields via jq
_jq() {
    printf '%s' "$input" | jq -r "$1 // empty"
}

# tmux status-bar integration
{
    mkdir -p ~/.cache/ai-usage 2>/dev/null
    echo "$input" | jq -c '{provider:"claude", model:.model.display_name, context_pct:(.context_window.used_percentage//0), context_size:(.context_window.context_window_size//0), cost_usd:(.cost.total_cost_usd//0), duration_ms:(.cost.total_duration_ms//0), rate_5h_pct:(.rate_limits.five_hour.used_percentage//-1), rate_7d_pct:(.rate_limits.seven_day.used_percentage//-1), updated_at:now|floor, resets_at_5h:(.rate_limits.five_hour.resets_at//-1), resets_at_7d:(.rate_limits.seven_day.resets_at//-1)}' > ~/.cache/ai-usage/claude.json 2>/dev/null &
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

# --- Git branch (bold cyan, leaf icon) ---
cwd=$(_jq '.workspace.current_dir')
if [ -n "$cwd" ]; then
    branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
fi
if [ -n "$branch" ]; then
    segments+=("${BOLD}${CYAN}${branch}${RESET}")
fi

# --- Context usage: dynamic emoji + colored percentage ---
used_pct=$(_jq '.context_window.used_percentage')
used_pct="${used_pct:-0}"
used_int=$(printf '%.0f' "$used_pct")
if [ "$used_int" -lt 20 ]; then
    ctx_color="$CTX_GREEN"
elif [ "$used_int" -lt 70 ]; then
    ctx_color="$CTX_YELLOW"
elif [ "$used_int" -lt 90 ]; then
    ctx_color="$CTX_ORANGE"
else
    ctx_color="$CTX_RED"
fi
segments+=("${ctx_color}${used_int}%${RESET}")

# --- Rate limit usage: 5-hour session and 7-day weekly (yellow, only present for subscribers) ---
five_hr=$(_jq '.rate_limits.five_hour.used_percentage')
five_hr_reset=$(_jq '.rate_limits.five_hour.resets_at')

seven_day=$(_jq '.rate_limits.seven_day.used_percentage')
seven_day_reset=$(_jq '.rate_limits.seven_day.resets_at')

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

if [ -n "$five_hr" ] || [ -n "$seven_day" ]; then
    limits_seg=""

    if [ -n "$five_hr" ]; then
        five_hr_int=$(printf '%.0f' "$five_hr")
        five_hr_remaining=$(format_remaining "$five_hr_reset")
        limits_seg="${YELLOW}5h ${five_hr_int}% (${five_hr_remaining})${RESET}"
    fi

    if [ -n "$seven_day" ]; then
        seven_day_int=$(printf '%.0f' "$seven_day")
        seven_day_remaining=$(format_remaining "$seven_day_reset")
        [ -n "$limits_seg" ] && limits_seg="${limits_seg} "
        limits_seg="${limits_seg}${YELLOW}7d ${seven_day_int}% (${seven_day_remaining})${RESET}"
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
        segments+=("${MAGENTA}${model} [${effort}]${RESET}")
    else
        segments+=("${MAGENTA}${model}${RESET}")
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
 
