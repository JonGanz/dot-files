#!/usr/bin/env bash
# lib.sh - helpers shared by every script in this directory.
#
# Source it, don't run it:   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# The sourcing script is expected to have set `set -euo pipefail` already.

# --- Paths -----------------------------------------------------------------

# Root of this (public) repo: one directory above scripts/.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Machine-local config (never committed) and machine-local state.
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/setup"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/setup"
LOCAL_ENV="$CONFIG_DIR/local.env"

# Every target path `link` has created, one per line. Used to find stale links.
LINK_STATE="$STATE_DIR/links"

# Set to 1 by --dry-run; `run` then prints commands instead of executing them.
DRY_RUN=0

# Defaults, overridden by local.env.
PROFILE=""
OVERLAY="$HOME/.config/setup-private"

# Absolute path of the private overlay repo, or "" if it isn't cloned here.
# Filled in by load_local_env.
OVERLAY_ROOT=""

# --- Output ----------------------------------------------------------------

info() { printf '  %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# run CMD...: execute CMD, or just print it when --dry-run is active.
# Use this for every command that changes the system.
run() {
  if ((DRY_RUN)); then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# --- Path helpers ----------------------------------------------------------

# expand_home PATH: turn a leading "~" into $HOME (the map and env files use "~").
expand_home() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s\n' "$HOME/${1#"~/"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# tilde_path PATH: the reverse of expand_home, for writing portable map lines.
tilde_path() {
  if [[ $1 == "$HOME"/* ]]; then
    printf '%s\n' "~/${1#"$HOME"/}"
  else
    printf '%s\n' "$1"
  fi
}

# --- Machine config --------------------------------------------------------

# load_local_env: read PROFILE/OVERLAY from local.env (if it exists) and work
# out OVERLAY_ROOT. The file is plain shell, written by bootstrap.
load_local_env() {
  if [[ -f $LOCAL_ENV ]]; then
    # shellcheck disable=SC1090
    source "$LOCAL_ENV"
  fi
  OVERLAY="$(expand_home "$OVERLAY")"
  if [[ -d $OVERLAY ]]; then
    OVERLAY_ROOT="$(cd "$OVERLAY" && pwd)"
  else
    OVERLAY_ROOT=""
  fi
}

# repo_roots: print each repo root, base first, then the overlay if present.
# Later roots win when two repos want to link the same target.
repo_roots() {
  printf '%s\n' "$REPO_ROOT"
  if [[ -n $OVERLAY_ROOT && $OVERLAY_ROOT != "$REPO_ROOT" ]]; then
    printf '%s\n' "$OVERLAY_ROOT"
  fi
}

# root_for NAME: map "base"/"overlay" (the --to argument) to a repo root.
root_for() {
  case "$1" in
    base) printf '%s\n' "$REPO_ROOT" ;;
    overlay)
      [[ -n $OVERLAY_ROOT ]] || die "no overlay repo found at $OVERLAY"
      printf '%s\n' "$OVERLAY_ROOT"
      ;;
    *) die "expected 'base' or 'overlay', got '$1'" ;;
  esac
}

# points_into_repo PATH: true if PATH lives inside any known repo root.
# This is how we recognise links that we created (and so may safely remove).
points_into_repo() {
  local root
  while IFS= read -r root; do
    [[ $1 == "$root"/* ]] && return 0
  done < <(repo_roots)
  return 1
}

# --- links.map -------------------------------------------------------------

# map_entries ROOT: parse ROOT/links.map and print "mode<TAB>src<TAB>target"
# for each rule, with "~" in the target already expanded.
# Format (whitespace separated, '#' starts a comment, no spaces in paths):
#   link      dotfiles/.bashrc   ~/.bashrc      link exactly this path
#   children  claude/skills      ~/.claude/skills   link each child of the folder
map_entries() {
  local map="$1/links.map" mode src dst
  [[ -f $map ]] || return 0
  while read -r mode src dst _; do
    # Skip blank lines and comments.
    [[ -z $mode || $mode == \#* ]] && continue
    [[ -n $src && -n $dst ]] || die "$map: malformed line: '$mode $src $dst'"
    [[ $mode == link || $mode == children ]] || die "$map: unknown mode '$mode'"
    printf '%s\t%s\t%s\n' "$mode" "$src" "$(expand_home "$dst")"
  done <"$map"
}

# desired_links: print "source<TAB>target" for every link all repos want.
# `link` rules give one pair each; `children` rules give one pair per child.
desired_links() {
  local root mode src dst child
  while IFS= read -r root; do
    while IFS=$'\t' read -r mode src dst; do
      case "$mode" in
        link)
          if [[ -e $root/$src || -L $root/$src ]]; then
            printf '%s\t%s\n' "$root/$src" "$dst"
          else
            warn "$root/links.map: source missing: $src"
          fi
          ;;
        children)
          # A children rule whose folder doesn't exist yet simply yields nothing.
          [[ -d $root/$src ]] || continue
          # .gitkeep only exists to keep empty folders in git; never link it.
          while IFS= read -r child; do
            printf '%s\t%s\n' "$child" "$dst/$(basename "$child")"
          done < <(find "$root/$src" -mindepth 1 -maxdepth 1 ! -name .gitkeep | sort)
          ;;
      esac
    done < <(map_entries "$root")
  done < <(repo_roots)
}

# --- Distro detection ------------------------------------------------------

# detect_distro: print ubuntu, arch, nixos, or unknown.
detect_distro() {
  local id="" id_like=""
  if [[ -r /etc/os-release ]]; then
    id="$(. /etc/os-release && printf '%s' "${ID:-}")"
    id_like="$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")"
  fi
  case " $id $id_like " in
    *" nixos "*) echo nixos ;;
    *" arch "*) echo arch ;;
    *" ubuntu "* | *" debian "*) echo ubuntu ;;
    *) echo unknown ;;
  esac
}

# is_wsl: true when running inside WSL (the kernel version string says so).
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# read_list FILE: print the entries of a package list, dropping comments/blanks.
read_list() {
  [[ -f $1 ]] || return 0
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"
}

# nix_cmd ARGS...: call nix with flakes enabled, whatever the installer defaulted to.
nix_cmd() {
  nix --extra-experimental-features 'nix-command flakes' "$@"
}
