#!/usr/bin/env bash

if [[ -r /etc/os-release ]]; then
    source /etc/os-release
else
    echo "Warning: /etc/os-release not found" >&2
fi

# Normalize fields to lowercase for comparison
_distro_id="${ID,,}"
_distro_like="${ID_LIKE,,}"

# Helper: check if a value exists in a space-separated list
_contains_word() {
  local needle="$1"
  shift
  for word in "$@"; do
    [[ "$word" == "$needle" ]] && return 0
  done
  return 1
}

# Main helper:
# is_distro <name>
#
# Behavior:
# - If <name> matches ID exactly → true
# - Otherwise, if <name> matches one of ID_LIKE → true
#
# This means:
#   is_distro ubuntu → true on ubuntu, pop, linuxmint, etc
#   is_distro pop    → true only on pop
#   is_distro arch   → true on arch, manjaro, etc
#
is_distro() {
  local target="${1,,}"

  # Exact match always wins
  [[ "$_distro_id" == "$target" ]] && return 0

  # Check ID_LIKE (space-separated)
  read -r -a like_array <<< "$_distro_like"
  _contains_word "$target" "${like_array[@]}"
}

# Optional helpers if you want stricter semantics

# Exact distro only (no derivatives)
is_distro_exact() {
  local target="${1,,}"
  [[ "$_distro_id" == "$target" ]]
}

# Family-only (must be via ID_LIKE, not exact ID)
is_distro_family() {
  local target="${1,,}"
  read -r -a like_array <<< "$_distro_like"
  _contains_word "$target" "${like_array[@]}"
}

