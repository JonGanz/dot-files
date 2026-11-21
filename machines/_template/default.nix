# Template for a new NixOS host. Directories starting with "_" are ignored by
# the flake; copy this one to add a machine:
#
#   cp -r machines/_template machines/<name>
#   cp /etc/nixos/configuration.nix /etc/nixos/hardware-configuration.nix machines/<name>/
#   git add machines/<name>          # flakes only see files git knows about
#   sudo nixos-rebuild switch --flake .#<name>
#
# <name> is just the flake's label for this host. The real hostname still comes
# from configuration.nix (networking.hostName).
{ ... }:
{
  # The installer's config: bootloader, hostname, your user, locale, KDE, and
  # its own import of hardware-configuration.nix.
  imports = [ ./configuration.nix ];

  # Settings from nixos/default.nix. See that file for all options.
  setup.profile = "personal"; # or "work"
  # setup.desktop = false;    # headless host: no KDE or GUI apps
}
