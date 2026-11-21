{
  description = "Machine setup: CLI package sets per profile";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # forAllSystems f: build f(pkgs) for each system in `systems`.
      # Unfree packages (e.g. claude-code) are allowed on purpose.
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs { inherit system; config.allowUnfree = true; }));

      # Tools every machine gets. GUI apps are NOT here: Nix GUI apps misbehave
      # off NixOS (no GL), so they come from native/ lists and flatpak instead.
      base = pkgs: with pkgs; [
        # essentials
        bats
        curl
        dos2unix
        ffmpeg
        fzf
        imagemagick
        jq
        ripgrep
        fd
        resvg
        shellcheck
        gitleaks
        tree
        unzip
        # core
        git
        tmux
        neovim
        lazygit
        lazydocker
        oh-my-posh
        # apps
        glow
        yazi
        claude-code
        opencode
        # sdks (node is pinned to the 24 line)
        nodejs_24
        rustup
        go
        python3
        python3Packages.pip
      ];

      # Extra tools per profile.
      personalExtra = pkgs: [ ];
      workExtra = pkgs: with pkgs; [
        ansible
        rsync
        lazysql
        taskwarrior3
        timewarrior
        github-copilot-cli
      ];

      # Maintained but not part of any profile. Install with:
      #   nix profile install .#optional
      optionalExtra = pkgs: with pkgs; [
        zellij
        zig_0_15
        syncthing
      ];

      # mkEnv: one installable environment named setup-<name>. bootstrap greps
      # for that name to tell whether the profile is already installed.
      mkEnv = pkgs: name: extra:
        pkgs.buildEnv {
          name = "setup-${name}";
          paths = base pkgs ++ extra pkgs;
        };
    in
    {
      # Installed with: nix profile install .#personal  (or .#work)
      packages = forAllSystems (pkgs: rec {
        personal = mkEnv pkgs "personal" personalExtra;
        work = mkEnv pkgs "work" workExtra;
        optional = mkEnv pkgs "optional" optionalExtra;
        default = personal;
      });

      # NixOS hosts go here, one per file in machines/, e.g.
      #   nixosConfigurations.myhost = nixpkgs.lib.nixosSystem { ... };
      nixosConfigurations = { };
    };
}
