# setup-nudge.sh - put "[setup:N] " in the prompt when N files are unmanaged.
#
# Loaded from ~/.bashrc with:
#   for f in ~/.bashrc.d/*.sh; do . "$f"; done
#
# The count comes from `setup status --count`, cached for 5 minutes so the
# prompt stays fast.

# This file is a symlink into the repo; follow it to find the repo root
# (three levels up: dotfiles/.bashrc.d/setup-nudge.sh -> repo).
__setup_repo="$(dirname "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")")"

# __setup_nudge: print the marker, or nothing when everything is managed.
__setup_nudge() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/setup-nudge" count
  # Refresh when the cache is missing or older than 5 minutes.
  if [[ ! -f $cache || -n $(find "$cache" -mmin +5 2>/dev/null) ]]; then
    mkdir -p "$(dirname "$cache")"
    "$__setup_repo/setup" status --count >"$cache" 2>/dev/null || echo 0 >"$cache"
  fi
  count="$(<"$cache")"
  if [[ $count =~ ^[0-9]+$ ]] && ((count > 0)); then
    printf '[setup:%s] ' "$count"
  fi
}

# Add it to the prompt once, even if this file is sourced repeatedly.
if [[ $PS1 != *__setup_nudge* ]]; then
  PS1='$(__setup_nudge)'"$PS1"
fi
