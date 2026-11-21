#!/usr/bin/env bash
# update.sh - upgrade everything this repo manages, then refresh links.
#
# Usage: ./setup update [--dry-run]
#
# Updates the flake lock (new nixpkgs), upgrades the Nix profile, upgrades
# native packages and flatpaks, then runs `link`. On NixOS it rebuilds the
# system for the current hostname instead of touching a Nix profile.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  sed -n '2,/^set -e/p' "${BASH_SOURCE[0]}" | sed -e '$d' -e 's/^# \{0,1\}//'
  exit "${1:-0}"
}

main() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      -h | --help) usage ;;
      *) usage 1 ;;
    esac
    shift
  done
  load_local_env

  case "$(detect_distro)" in
    nixos)
      run nix_cmd flake update --flake "$REPO_ROOT"
      run sudo nixos-rebuild switch --flake "$REPO_ROOT#$(hostname)"
      ;;
    ubuntu)
      run nix_cmd flake update --flake "$REPO_ROOT"
      run nix_cmd profile upgrade --all
      run sudo apt-get update
      run sudo apt-get upgrade -y
      ;;
    arch)
      run nix_cmd flake update --flake "$REPO_ROOT"
      run nix_cmd profile upgrade --all
      run sudo pacman -Syu --noconfirm
      ;;
    *) die "unsupported distro" ;;
  esac

  # Flatpaks exist only where GUI apps were installed.
  if command -v flatpak >/dev/null; then
    run flatpak update -y --noninteractive
  fi

  if ((DRY_RUN)); then
    "$REPO_ROOT/scripts/link.sh" --dry-run
  else
    "$REPO_ROOT/scripts/link.sh"
  fi
}

main "$@"
