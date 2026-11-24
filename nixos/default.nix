# nixos/default.nix - the NixOS module shared by every host in machines/.
#
# It adds this repo's package lists and desktop/dev defaults on top of whatever
# the host's own configuration.nix (usually the installer's) already says.
# Host-specific choices go in machines/<host>/default.nix via `setup.*` below.
{ config, lib, pkgs, ... }:

let
  cfg = config.setup;
  packages = import ../packages.nix pkgs;
in
{
  # --- Options a host can set -----------------------------------------------
  options.setup = {
    profile = lib.mkOption {
      type = lib.types.enum [ "personal" "work" ];
      description = "Which package profile (see packages.nix) this machine gets.";
    };
    desktop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Desktop apps and fonts. Turn off for headless hosts.";
    };
    plasma = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Switch the machine to KDE Plasma + SDDM, turning off GNOME/GDM.
        Leave false to keep whatever desktop the installer set up.
      '';
    };
  };

  config = lib.mkMerge [
    # --- Always on ----------------------------------------------------------
    {
      # Flakes and the `nix` command, which this whole repo relies on.
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # claude-code and a few others are unfree.
      nixpkgs.config.allowUnfree = true;

      # The CLI tools for this profile, available to every user.
      environment.systemPackages = packages.forProfile cfg.profile;

      # Rootless docker, as in the old setup. DOCKER_HOST is set for you.
      virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };
    }

    # --- Optional switch to KDE ---------------------------------------------
    # Only one display manager may be enabled, so the installer's GNOME/GDM
    # (set in the host's configuration.nix) is overridden with mkForce.
    (lib.mkIf (cfg.desktop && cfg.plasma) {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.gnome.enable = lib.mkForce false;
      services.displayManager.gdm.enable = lib.mkForce false;
    })

    # --- Desktop ------------------------------------------------------------
    (lib.mkIf cfg.desktop {
      environment.systemPackages = packages.desktopForProfile cfg.profile;

      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

      programs.steam.enable = cfg.profile == "personal";
    })
  ];
}
