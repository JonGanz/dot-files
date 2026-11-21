#!/usr/bin/env bash
# link.sh - make the symlinks described by every repo's links.map.
#
# Usage: ./setup link [--dry-run] [--backup]
#
# Rules of engagement:
#   - Missing target             -> create the link.
#   - Link already correct       -> leave it.
#   - Link into a repo, wrong    -> repoint it.
#   - Real file/dir in the way   -> skip and report (or move aside with --backup).
#   - Link to somewhere else     -> skip and report.
#   - Link we made earlier that is no longer wanted -> remove it, but only if
#     it still points into a repo. Real files are never deleted.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BACKUP=0

# Counters for the summary line.
created=0 relinked=0 removed=0 blocked=0

# target -> source, for every link we want. `order` keeps a stable sequence.
declare -A desired=()
# Targets that are correctly linked after this run (written to the state file).
declare -a kept=()

usage() {
  sed -n '2,/^set -e/p' "${BASH_SOURCE[0]}" | sed -e '$d' -e 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# collect_desired: fill `desired` from all repos. If two repos want the same
# target, the later one (the overlay) wins.
collect_desired() {
  local source target
  while IFS=$'\t' read -r source target; do
    if [[ -n ${desired[$target]+x} && ${desired[$target]} != "$source" ]]; then
      warn "$target: ${desired[$target]} overridden by $source"
    fi
    desired[$target]=$source
  done < <(desired_links)
}

# link_one SOURCE TARGET: bring a single target to the desired state.
link_one() {
  local source="$1" target="$2" current

  if [[ -L $target ]]; then
    current="$(readlink "$target")"
    if [[ $current == "$source" ]]; then
      kept+=("$target")
    elif points_into_repo "$current"; then
      # One of our links, pointing at the wrong place (e.g. file moved repos).
      run ln -sfn "$source" "$target"
      info "relinked  $target"
      relinked=$((relinked + 1))
      kept+=("$target")
    else
      warn "skipped $target: symlink to $current (not ours)"
      blocked=$((blocked + 1))
    fi
  elif [[ -e $target ]]; then
    if ((BACKUP)); then
      local backup
      backup="$target.bak.$(date +%Y%m%d%H%M%S)"
      run mv "$target" "$backup"
      info "backed up $target -> $backup"
      run ln -s "$source" "$target"
      created=$((created + 1))
      kept+=("$target")
    else
      warn "skipped $target: real file in the way (use 'setup adopt' or --backup)"
      blocked=$((blocked + 1))
    fi
  else
    run mkdir -p "$(dirname "$target")"
    run ln -s "$source" "$target"
    info "linked    $target"
    created=$((created + 1))
    kept+=("$target")
  fi
}

# remove_if_ours TARGET: delete TARGET only if it is a symlink we could have
# made: it points into a repo, or it dangles (the repo file is gone).
remove_if_ours() {
  local target="$1"
  [[ -L $target ]] || return 0 # real file or already gone: leave it alone
  if points_into_repo "$(readlink "$target")" || [[ ! -e $target ]]; then
    run rm "$target"
    info "removed   $target (stale)"
    removed=$((removed + 1))
  fi
}

# prune_stale: remove links that earlier runs made but that are no longer wanted.
prune_stale() {
  local old
  if [[ -f $LINK_STATE ]]; then
    # Normal case: diff the previous run's list against what we want now.
    while IFS= read -r old; do
      [[ -n ${desired[$old]+x} ]] || remove_if_ours "$old"
    done <"$LINK_STATE"
  else
    # No state file (first run, or it was deleted): fall back to scanning the
    # directories the maps link into for repo-pointing links we don't want.
    local dir
    while IFS= read -r dir; do
      [[ -d $dir ]] || continue
      while IFS= read -r old; do
        [[ -n ${desired[$old]+x} ]] || remove_if_ours "$old"
      done < <(find "$dir" -mindepth 1 -maxdepth 1 -type l)
    done < <(scan_dirs)
  fi
}

# scan_dirs: every directory some map rule links into (deduplicated).
scan_dirs() {
  local root mode src dst
  while IFS= read -r root; do
    while IFS=$'\t' read -r mode src dst; do
      if [[ $mode == children ]]; then
        printf '%s\n' "$dst"
      else
        dirname "$dst"
      fi
    done < <(map_entries "$root")
  done < <(repo_roots) | sort -u
}

# write_state: record what we now manage, for the next run's stale check.
write_state() {
  ((DRY_RUN)) && return 0
  mkdir -p "$STATE_DIR"
  # `printf` with an empty array would emit a blank line, so guard it.
  if ((${#kept[@]})); then
    printf '%s\n' "${kept[@]}" | sort -u >"$LINK_STATE.tmp"
  else
    : >"$LINK_STATE.tmp"
  fi
  mv "$LINK_STATE.tmp" "$LINK_STATE"
}

# fix_ssh_perms: git only stores the executable bit, so private keys arrive
# group/world-readable and ssh refuses them. Tighten anything linked into ~/.ssh.
fix_ssh_perms() {
  local target source
  for target in "${kept[@]}"; do
    [[ $target == "$HOME/.ssh/"* ]] || continue
    source="${desired[$target]}"
    # Public keys and config can stay readable; everything else is locked down.
    if [[ -f $source && $target != *.pub ]]; then
      run chmod 600 "$source"
    fi
  done
  [[ -d $HOME/.ssh ]] && run chmod 700 "$HOME/.ssh"
  return 0
}

main() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --backup) BACKUP=1 ;;
      -h | --help) usage ;;
      *) usage 1 ;;
    esac
    shift
  done

  load_local_env
  collect_desired

  # Process targets in sorted order so output is stable between runs.
  local target
  if ((${#desired[@]})); then
    while IFS= read -r target; do
      link_one "${desired[$target]}" "$target"
    done < <(printf '%s\n' "${!desired[@]}" | sort)
  fi

  prune_stale
  fix_ssh_perms
  write_state

  printf 'created %d, relinked %d, removed %d, blocked %d\n' \
    "$created" "$relinked" "$removed" "$blocked"
}

main "$@"
