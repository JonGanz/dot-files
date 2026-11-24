#!/usr/bin/env bash
# bootstrap.sh - first-time (and repeatable) setup of this machine.
#
# Usage: ./setup bootstrap [--profile personal|work] [--cli-only] [--dry-run]
#
#   --profile   which Nix package set to install; remembered in local.env
#   --cli-only  skip GUI apps (implied inside WSL)
#   --dry-run   print what would run, change nothing
#
# Steps (each is idempotent): local.env, Nix, native packages, Nix profile,
# SSH key, gitleaks pre-commit hook, symlinks. On NixOS the packages come from
# `nixos-rebuild switch --flake .#<host>` (run that first), so the Nix, native
# package and Nix profile steps are skipped there.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

CLI_ONLY=0
DISTRO=""

usage() {
  sed -n '2,/^set -e/p' "${BASH_SOURCE[0]}" | sed -e '$d' -e 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# write_local_env: create local.env, or update PROFILE in it if one is given.
# OVERLAY is left alone so a hand-edited path survives.
write_local_env() {
  echo "[1/7] machine config ($LOCAL_ENV)"
  if ((DRY_RUN)); then
    info "would set PROFILE=$PROFILE"
    return 0
  fi
  mkdir -p "$CONFIG_DIR"
  if [[ ! -f $LOCAL_ENV ]]; then
    {
      echo "# Machine-local settings for ./setup. Never committed."
      echo "PROFILE=$PROFILE"
      echo "# Private overlay repo, layered over this one (optional):"
      echo "OVERLAY=~/.config/setup-private"
    } >"$LOCAL_ENV"
  else
    # Rewrite just the PROFILE line.
    sed -i "s/^PROFILE=.*/PROFILE=$PROFILE/" "$LOCAL_ENV"
  fi
}

# install_nix: install Nix with the Determinate installer unless it's present.
# This pipes a remote script into sh, the installer's documented method;
# read it first at https://install.determinate.systems if that bothers you.
install_nix() {
  echo "[2/7] Nix"
  if command -v nix >/dev/null; then
    info "already installed"
    return 0
  fi
  run sh -c "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"
  # Make nix usable in this shell without logging out.
  if ((!DRY_RUN)); then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

# collect_lists NAME: print package names from native/NAME.txt and
# native/NAME.<profile>.txt in every repo (so the overlay can add its own).
collect_lists() {
  local name="$1" root
  while IFS= read -r root; do
    read_list "$root/native/$name.txt"
    read_list "$root/native/$name.$PROFILE.txt"
  done < <(repo_roots)
}

# install_native: system packages, plus desktop packages and flatpaks unless
# --cli-only. The "-desktop" lists hold GUI apps and anything WSL gets from
# Windows instead (docker, fonts).
install_native() {
  echo "[3/7] native packages ($DISTRO)"
  local -a pkgs=() apps=()
  case "$DISTRO" in
    ubuntu)
      mapfile -t pkgs < <(collect_lists apt)
      ((CLI_ONLY)) || mapfile -t -O "${#pkgs[@]}" pkgs < <(collect_lists apt-desktop)
      ((${#pkgs[@]})) && {
        run sudo apt-get update
        run sudo apt-get install -y "${pkgs[@]}"
      }
      ;;
    arch)
      mapfile -t pkgs < <(collect_lists pacman)
      ((CLI_ONLY)) || mapfile -t -O "${#pkgs[@]}" pkgs < <(collect_lists pacman-desktop)
      ((${#pkgs[@]})) && run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
      ;;
  esac

  # Flatpaks are desktop-only.
  if ((!CLI_ONLY)); then
    mapfile -t apps < <(collect_lists flatpak)
    if ((${#apps[@]})); then
      run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      run flatpak install -y --noninteractive flathub "${apps[@]}"
    fi
  fi
  return 0
}

# install_nix_profile: install (or refresh) the flake package set for PROFILE.
install_nix_profile() {
  echo "[4/7] Nix packages (profile: $PROFILE)"
  # The built environment is named setup-<profile>, and that name appears in
  # its store path, so grep the profile listing for it.
  if ! ((DRY_RUN)) && nix_cmd profile list 2>/dev/null | grep -q "setup-$PROFILE"; then
    info "already installed; upgrading"
    nix_cmd profile upgrade --all
  else
    run nix --extra-experimental-features 'nix-command flakes' \
      profile install "$REPO_ROOT#$PROFILE"
  fi
}

# setup_ssh_key: create an ed25519 key if none exists, insisting on a passphrase.
setup_ssh_key() {
  echo "[5/7] SSH key"
  local key="$HOME/.ssh/id_ed25519"
  if [[ -f $key ]]; then
    info "$key exists"
    return 0
  fi
  if ((DRY_RUN)); then
    info "would generate $key (passphrase required)"
    return 0
  fi
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  while true; do
    # ssh-keygen prompts for the passphrase itself, so it never appears in
    # `ps` output. Afterwards we check the key really is encrypted: asking
    # for the public key with an empty passphrase succeeds only if it isn't.
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$key"
    if ssh-keygen -y -P "" -f "$key" >/dev/null 2>&1; then
      warn "that key has no passphrase; discarding it. Please set one."
      rm -f "$key" "$key.pub"
    else
      break
    fi
  done
  info "public key (add it to GitHub etc.):"
  sed 's/^/    /' "$key.pub"
}

# install_hooks: pre-commit hook running gitleaks, in every repo that exists.
install_hooks() {
  echo "[6/7] gitleaks pre-commit hook"
  local root hook
  while IFS= read -r root; do
    [[ -d $root/.git ]] || continue
    hook="$root/.git/hooks/pre-commit"
    if ((DRY_RUN)); then
      info "would write $hook"
      continue
    fi
    cat >"$hook" <<'HOOK'
#!/usr/bin/env bash
# Installed by ./setup bootstrap. Blocks commits that contain secrets.
if ! command -v gitleaks >/dev/null; then
  echo "pre-commit: gitleaks not found, skipping secret scan" >&2
  exit 0
fi
# Newer gitleaks uses `git --staged`; older versions use `protect --staged`.
gitleaks git --pre-commit --staged --redact 2>/dev/null \
  || gitleaks protect --staged --redact
HOOK
    chmod +x "$hook"
    info "wrote $hook"
  done < <(repo_roots)
}

# ensure_bashrc_loader: make ~/.bashrc source every ~/.bashrc.d/*.sh. The block
# between the markers is rewritten on each run, so edits to it are replaced.
ensure_bashrc_loader() {
  local rc="$HOME/.bashrc" begin="# >>> setup:bashrc.d >>>" end="# <<< setup:bashrc.d <<<"
  local block
  block="$begin"$'\n''for f in "$HOME"/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done'$'\n'"$end"
  if ((DRY_RUN)); then
    info "would ensure the bashrc.d loader block in $rc"
    return 0
  fi
  touch "$rc"
  # Drop any previous block, then append the current one.
  sed -i "\|$begin|,\|$end|d" "$rc"
  printf '%s\n' "$block" >>"$rc"
}

# ensure_login_profile: login shells (most terminal emulators on NixOS) read
# ~/.bash_profile, ~/.bash_login or ~/.profile instead of ~/.bashrc. If none of
# them exists, create ~/.bash_profile that loads ~/.bashrc. An existing one is
# left alone (Ubuntu's stock ~/.profile already sources ~/.bashrc).
ensure_login_profile() {
  local f
  for f in .bash_profile .bash_login .profile; do
    [[ -e $HOME/$f ]] && return 0
  done
  if ((DRY_RUN)); then
    info "would create ~/.bash_profile to load ~/.bashrc"
    return 0
  fi
  printf '%s\n' '# Login shells: load ~/.bashrc too. Created by ./setup bootstrap.' \
    '[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"' >"$HOME/.bash_profile"
}

# link_dotfiles: install the bashrc loader, then hand over to link.sh
# (forwarding --dry-run).
link_dotfiles() {
  echo "[7/7] symlinks"
  ensure_bashrc_loader
  ensure_login_profile
  if ((DRY_RUN)); then
    "$REPO_ROOT/scripts/link.sh" --dry-run
  else
    "$REPO_ROOT/scripts/link.sh"
  fi
}

main() {
  while (($#)); do
    case "$1" in
      --profile) PROFILE="${2:?--profile needs personal|work}"; shift ;;
      --cli-only) CLI_ONLY=1 ;;
      --dry-run) DRY_RUN=1 ;;
      -h | --help) usage ;;
      *) usage 1 ;;
    esac
    shift
  done

  # An explicit --profile wins; otherwise use what local.env remembered.
  local requested="$PROFILE"
  load_local_env
  [[ -n $requested ]] && PROFILE="$requested"
  [[ $PROFILE == personal || $PROFILE == work ]] \
    || die "pass --profile personal|work (none remembered in $LOCAL_ENV)"

  DISTRO="$(detect_distro)"
  case "$DISTRO" in
    unknown) die "unsupported distro (need Ubuntu/Debian or Arch)" ;;
  esac
  if is_wsl; then
    CLI_ONLY=1
    info "WSL detected: GUI apps skipped"
  fi

  write_local_env
  # Re-read so the overlay path from local.env is in effect for later steps.
  load_local_env
  if [[ $DISTRO == nixos ]]; then
    info "NixOS: packages come from nixos-rebuild; skipping Nix, native and profile steps"
  else
    install_nix
    install_native
    install_nix_profile
  fi
  setup_ssh_key
  install_hooks
  link_dotfiles
  echo "done."
}

main "$@"
