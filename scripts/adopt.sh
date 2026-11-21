#!/usr/bin/env bash
# adopt.sh - move an on-disk file/dir into a repo and link it back in place.
#
# Usage: ./setup adopt <path> --to base|overlay [--as <repo-path>] [--yes] [--dry-run]
#
#   <path>            the real file or directory, e.g. ~/.claude/skills/foo
#   --to base         adopt into this repo
#   --to overlay      adopt into the private overlay repo
#   --as <repo-path>  destination inside the repo (skips guessing)
#   --yes             accept a guessed destination without asking
#
# Without --as, the destination is guessed:
#   1. <path> is directly inside the target of a `children` rule
#      -> <that rule's repo folder>/<name>      (no links.map change needed
#         beyond making sure the chosen repo has the rule)
#   2. otherwise, under $HOME -> dotfiles/<path relative to $HOME>,
#      and a `link` line is appended to links.map
#   3. otherwise -> error, use --as
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  sed -n '2,/^set -e/p' "${BASH_SOURCE[0]}" | sed -e '$d' -e 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# find_children_rule DIR: print the repo folder of the first `children` rule
# (searching every repo's map) whose target is DIR. Prints nothing if none.
find_children_rule() {
  local dir="$1" root mode src dst
  while IFS= read -r root; do
    while IFS=$'\t' read -r mode src dst; do
      if [[ $mode == children && $dst == "$dir" ]]; then
        printf '%s\n' "$src"
        return 0
      fi
    done < <(map_entries "$root")
  done < <(repo_roots)
  return 0
}

# guess_repo_path PATH: print the repo-relative destination for PATH (rules 1-3
# in the header). Dies if it cannot decide.
guess_repo_path() {
  local path="$1" rule
  rule="$(find_children_rule "$(dirname "$path")")"
  if [[ -n $rule ]]; then
    printf '%s/%s\n' "$rule" "$(basename "$path")"
    return 0
  fi
  [[ $path == "$HOME"/* ]] || die "$path is outside \$HOME; pass --as <repo-path>"
  printf 'dotfiles/%s\n' "${path#"$HOME"/}"
}

# map_has ROOT MODE SRC TARGET: true if ROOT's links.map already has this rule.
# TARGET must be fully expanded (no "~").
map_has() {
  local root="$1" want_mode="$2" want_src="$3" want_dst="$4" mode src dst
  while IFS=$'\t' read -r mode src dst; do
    [[ $mode == "$want_mode" && $src == "$want_src" && $dst == "$want_dst" ]] && return 0
  done < <(map_entries "$root")
  return 1
}

# plan_map_line ROOT PATH REL: print "mode<TAB>src<TAB>target" for the rule that
# should cover PATH once it lives at ROOT/REL, or print nothing if ROOT's map
# already has it.
plan_map_line() {
  local root="$1" path="$2" rel="$3" parent rule
  parent="$(dirname "$path")"
  rule="$(find_children_rule "$parent")"
  if [[ -n $rule && $rule == "$(dirname "$rel")" ]]; then
    # Covered by a children rule; just make sure this repo's map has it too.
    map_has "$root" children "$rule" "$parent" || printf 'children\t%s\t%s\n' "$rule" "$parent"
  else
    printf 'link\t%s\t%s\n' "$rel" "$path"
  fi
}

# append_map_line ROOT "mode<TAB>src<TAB>target": add a rule to ROOT/links.map.
append_map_line() {
  local map="$1/links.map" mode src dst
  IFS=$'\t' read -r mode src dst <<<"$2"
  # Make sure the file ends in a newline before appending.
  if [[ -s $map && -n $(tail -c1 "$map") ]]; then
    echo >>"$map"
  fi
  printf '%-11s %-24s %s\n' "$mode" "$src" "$(tilde_path "$dst")" >>"$map"
}

# record_in_state TARGET: note that we manage TARGET, so a later `link` run can
# remove it if it is ever deleted from the repo (state is otherwise only
# written by `link`).
record_in_state() {
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$1" >>"$LINK_STATE"
}

main() {
  local path="" to="" as="" yes=0
  while (($#)); do
    case "$1" in
      --to) to="${2:?--to needs base|overlay}"; shift ;;
      --as) as="${2:?--as needs a repo path}"; shift ;;
      --yes) yes=1 ;;
      --dry-run) DRY_RUN=1 ;;
      -h | --help) usage ;;
      -*) usage 1 ;;
      *) path="$1" ;;
    esac
    shift
  done
  [[ -n $path && -n $to ]] || usage 1

  load_local_env

  # Absolute path, without resolving a final symlink (we want the item itself).
  path="$(realpath -s -- "$path")"
  [[ -e $path || -L $path ]] || die "$path does not exist"
  if [[ -L $path ]] && points_into_repo "$(readlink "$path")"; then
    die "$path is already managed"
  fi

  local root rel guessed=0 dest
  root="$(root_for "$to")"
  if [[ -n $as ]]; then
    rel="${as#/}"
  else
    rel="$(guess_repo_path "$path")"
    guessed=1
  fi
  dest="$root/$rel"
  [[ ! -e $dest && ! -L $dest ]] || die "destination already exists: $dest"

  local map_line
  map_line="$(plan_map_line "$root" "$path" "$rel")"

  printf 'move  %s\n  to  %s\nlink  %s -> %s\n' "$path" "$dest" "$path" "$dest"
  [[ -n $map_line ]] && printf 'add to %s/links.map: %s\n' "$root" "${map_line//$'\t'/ }"

  # A guessed destination needs a human check unless --yes was given.
  if ((guessed && !yes && !DRY_RUN)); then
    [[ -t 0 ]] || die "destination was guessed; rerun with --yes or --as"
    read -r -p "Proceed? [y/N] " answer
    [[ $answer == [yY]* ]] || die "aborted"
  fi

  run mkdir -p "$(dirname "$dest")"
  run mv "$path" "$dest"
  run ln -s "$dest" "$path"
  if ((!DRY_RUN)); then
    [[ -n $map_line ]] && append_map_line "$root" "$map_line"
    record_in_state "$path"
  fi

  ((DRY_RUN)) || printf 'adopted. Remember to commit in %s\n' "$root"
}

main "$@"
