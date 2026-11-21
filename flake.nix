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

      # mkEnv: one installable environment named setup-<name>. bootstrap greps
      # for that name to tell whether the profile is already installed.
      # The package lists themselves live in packages.nix.
      mkEnv = pkgs: name: extra:
        pkgs.buildEnv {
          name = "setup-${name}";
          paths = (import ./packages.nix pkgs).base ++ extra;
        };

      # Every directory in machines/ (except ones starting with "_") is a NixOS
      # host, built from nixos/default.nix plus that directory.
      hostNames = builtins.filter (name: !(nixpkgs.lib.hasPrefix "_" name))
        (builtins.attrNames
          (nixpkgs.lib.filterAttrs (_: type: type == "directory")
            (builtins.readDir ./machines)));
    in
    {
      # Installed with: nix profile install .#personal  (or .#work)
      packages = forAllSystems (pkgs: rec {
        personal = mkEnv pkgs "personal" (import ./packages.nix pkgs).personal;
        work = mkEnv pkgs "work" (import ./packages.nix pkgs).work;
        optional = mkEnv pkgs "optional" (import ./packages.nix pkgs).optional;
        default = personal;
      });

      # Built with: sudo nixos-rebuild switch --flake .#<directory name>
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (name:
        nixpkgs.lib.nixosSystem {
          modules = [ ./nixos ./machines/${name} ];
        });
    };
}
