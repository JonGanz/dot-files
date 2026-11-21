{
  description = "Machine setup: CLI package sets per profile";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # forAllSystems f: build f(pkgs) for each system in `systems`.
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # Tools every machine gets.
      base = pkgs: with pkgs; [
        git
        neovim
        tmux
        taskwarrior3
        ripgrep
        fd
        jq
        gitleaks
        shellcheck
      ];

      # Extra tools per profile. Add to these lists as needs diverge.
      personalExtra = pkgs: [ ];
      workExtra = pkgs: [ ];

      # mkEnv: one installable environment named setup-<profile>. bootstrap
      # greps for that name to tell whether the profile is already installed.
      mkEnv = pkgs: profile: extra:
        pkgs.buildEnv {
          name = "setup-${profile}";
          paths = base pkgs ++ extra pkgs;
        };
    in
    {
      # Installed with: nix profile install .#personal  (or .#work)
      packages = forAllSystems (pkgs: rec {
        personal = mkEnv pkgs "personal" personalExtra;
        work = mkEnv pkgs "work" workExtra;
        default = personal;
      });

      # NixOS hosts go here, one per file in machines/, e.g.
      #   nixosConfigurations.myhost = nixpkgs.lib.nixosSystem { ... };
      nixosConfigurations = { };
    };
}
