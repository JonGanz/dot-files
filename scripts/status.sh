#!/usr/bin/env bash
# status.sh - show what is out of sync between the repos and the machine.
#
# Usage: ./setup status [--count]
#
# Reports four things:
#   unmanaged  entries inside a `children` folder (e.g. ~/.claude/skills/foo)
#              that no repo owns yet -> candidates for `setup adopt`
#   blocked    real files sitting where a link should be
#   unlinked   links the maps want that don't exist yet -> run `setup link`
#   drift      uncommitted changes in each repo (git status)
#
# --count prints only the number of unmanaged items (used by the shell prompt).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# unmanaged_items: print every entry in a children target dir that is not a
# symlink into one of our repos.
unmanaged_items() {
  local root mode src dst entry link
  while IFS= read -r root; do
    while IFS=$'\t' read -r mode src dst; do
      [[ $mode == children && -d $dst ]] || continue
      while IFS= read -r entry; do
        if [[ -L $entry ]]; then
          link="$(readlink "$entry")"
          points_into_repo "$link" && continue # managed
        fi
        printf '%s\n' "$entry"
      done < <(find "$dst" -mindepth 1 -maxdepth 1 | sort)
    done < <(map_entries "$root")
  done < <(repo_roots) | sort -u
}

# link_problems: compare desired links with reality; print "blocked PATH" or
# "unlinked PATH" lines.
link_problems() {
  local source target
  while IFS=$'\t' read -r source target; do
    if [[ -L $target ]]; then
      [[ $(readlink "$target") == "$source" ]] || printf 'blocked %s (links elsewhere)\n' "$target"
    elif [[ -e $target ]]; then
      printf 'blocked %s (real file)\n' "$target"
    else
      printf 'unlinked %s\n' "$target"
    fi
  done < <(desired_links)
}

# print_section TITLE: read stdin; print it under TITLE, or nothing if empty.
print_section() {
  local title="$1" lines
  lines="$(cat)"
  [[ -n $lines ]] || return 0
  printf '%s:\n' "$title"
  sed 's/^/  /' <<<"$lines"
}

main() {
  load_local_env

  if [[ ${1:-} == --count ]]; then
    unmanaged_items | wc -l
    return 0
  fi

  unmanaged_items | print_section "unmanaged (adopt these)"

  local problems
  problems="$(link_problems)"
  grep '^blocked' <<<"$problems" | sed 's/^blocked //' | print_section "blocked" || true
  grep '^unlinked' <<<"$problems" | sed 's/^unlinked //' | print_section "unlinked (run 'setup link')" || true

  # Show uncommitted changes in each repo.
  local root changes
  while IFS= read -r root; do
    changes="$(git -C "$root" status --short 2>/dev/null || true)"
    [[ -n $changes ]] && printf 'drift in %s:\n%s\n' "$root" "$(sed 's/^/  /' <<<"$changes")"
  done < <(repo_roots)
  return 0
}

main "$@"
