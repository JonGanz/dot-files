#!/usr/bin/env bash
# cruft.sh - find installed software that is never run.
#
# Usage: ./setup cruft enable [--dry-run]   start logging every program exec
#        ./setup cruft report               list packages whose programs never ran
#
# `enable` installs an auditd rule that logs every execve() system call.
# `report` reads that log and compares the programs that ran against the
# programs shipped by your Nix profile and your manually installed apt/pacman
# packages. Packages with none of their programs in the log are listed.
#
# Needs a kernel with auditing, so it does not work on WSL. Let it collect for
# a few weeks before trusting the report: rarely used tools look unused early.
# Scripts show up under their `comm` name, which the kernel truncates to 15
# characters, so a very long script name may be wrongly reported as unused.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

RULES_FILE=/etc/audit/rules.d/setup-cruft.rules
AUDIT_KEY=setup-cruft
SINCE_FILE="$STATE_DIR/cruft-since"

# used: set of program names seen executing (basename of exe, plus comm).
declare -A used=()

usage() {
  sed -n '2,/^set -e/p' "${BASH_SOURCE[0]}" | sed -e '$d' -e 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# require_audit_kernel: stop early where auditing can't work.
require_audit_kernel() {
  if is_wsl; then
    die "kernel auditing is unavailable on WSL; cruft reports are skipped there"
  fi
}

# enable_auditing: install auditd if missing, add the execve rule, load it.
enable_auditing() {
  require_audit_kernel
  if ! command -v auditctl >/dev/null; then
    case "$(detect_distro)" in
      ubuntu) run sudo apt-get install -y auditd ;;
      arch) run sudo pacman -S --needed --noconfirm audit ;;
      *) die "install auditd manually, then rerun" ;;
    esac
  fi

  # One rule: log every execve (program start) on 64-bit syscalls, tagged with
  # our key so the report can pull out just these records.
  local rule="-a always,exit -F arch=b64 -S execve -k $AUDIT_KEY"
  if ((DRY_RUN)); then
    echo "[dry-run] write '$rule' to $RULES_FILE"
  else
    echo "$rule" | sudo tee "$RULES_FILE" >/dev/null
  fi
  run sudo augenrules --load
  run sudo systemctl enable --now auditd

  # Remember when logging began so the report can say how much data it has.
  if ((!DRY_RUN)); then
    mkdir -p "$STATE_DIR"
    [[ -f $SINCE_FILE ]] || date -I >"$SINCE_FILE"
  fi
  echo "auditing enabled. Check back with './setup cruft report' in a few weeks."
}

# load_used: fill `used` from the audit log.
load_used() {
  local name
  # -i turns numeric fields into names; exe= is the program, comm= its short
  # name (for scripts, that is the script's name rather than the interpreter's).
  while IFS= read -r name; do
    used["$(basename "$name")"]=1
  done < <(
    sudo ausearch -k "$AUDIT_KEY" -i 2>/dev/null \
      | grep -oE '(exe=[^ ]+|comm="?[^" ]+)' \
      | sed -E 's/^(exe|comm)="?//' \
      | sort -u
  )
  ((${#used[@]})) || die "no audit records for key '$AUDIT_KEY'; run './setup cruft enable' first"
}

# check_package MANAGER PACKAGE BIN...: print PACKAGE if none of its BINs ran.
check_package() {
  local manager="$1" package="$2" bin
  shift 2
  (($#)) || return 0 # libraries and data packages have no programs; skip
  for bin in "$@"; do
    [[ -n ${used[$bin]+x} ]] && return 0
  done
  printf 'unused  %-7s %s  (%s)\n' "$manager" "$package" "$*"
}

# report_nix: each program in the Nix profile is treated as its own package.
report_nix() {
  local bin_dir="$HOME/.nix-profile/bin" bin
  [[ -d $bin_dir ]] || return 0
  while IFS= read -r bin; do
    check_package nix "$bin" "$bin"
  done < <(ls "$bin_dir")
}

# report_apt: manually installed packages and the programs they ship.
report_apt() {
  command -v apt-mark >/dev/null || return 0
  local pkg
  while IFS= read -r pkg; do
    # shellcheck disable=SC2046 # word splitting of the name list is intended
    check_package apt "$pkg" $(dpkg -L "$pkg" 2>/dev/null \
      | grep -E '^/usr/(s?bin|games)/[^/]+$' | xargs -r -n1 basename)
  done < <(apt-mark showmanual)
}

# report_pacman: explicitly installed packages and the programs they ship.
report_pacman() {
  command -v pacman >/dev/null || return 0
  local pkg
  while IFS= read -r pkg; do
    # shellcheck disable=SC2046
    check_package pacman "$pkg" $(pacman -Ql "$pkg" 2>/dev/null \
      | awk '{print $2}' | grep -E '^/usr/(s?bin)/[^/]+$' | xargs -r -n1 basename)
  done < <(pacman -Qqe)
}

report() {
  require_audit_kernel
  [[ -f $SINCE_FILE ]] && echo "audit data since $(<"$SINCE_FILE")"
  load_used
  report_nix
  report_apt
  report_pacman
}

main() {
  local cmd="${1:-}"
  shift || true
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      *) usage 1 ;;
    esac
    shift
  done
  load_local_env
  case "$cmd" in
    enable) enable_auditing ;;
    report) report ;;
    -h | --help) usage ;;
    *) usage 1 ;;
  esac
}

main "$@"
