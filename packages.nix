# packages.nix - every package list lives here, as a function of `pkgs`.
#
# Used by flake.nix (an installable bundle for Ubuntu/Arch/WSL) and by
# nixos/default.nix (system packages on NixOS), so adding a tool here adds it
# everywhere. Other distros install GUI apps from native/ instead (Nix GUI apps
# misbehave off NixOS), which is why the `desktop*` lists are NixOS-only.
pkgs:
rec {
  # Tools every machine gets.
  base = with pkgs; [
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
    # build tools neovim plugins (treesitter) need to compile parsers
    gcc
    gnumake
    tree-sitter
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

  # Extra tools per profile. Add to these lists as needs diverge.
  personal = [ ];
  work = with pkgs; [
    ansible
    rsync
    lazysql
    taskwarrior3
    timewarrior
    github-copilot-cli
  ];

  # Maintained but not part of any profile. Install with:
  #   nix profile install .#optional
  optional = with pkgs; [
    zellij
    zig_0_15
    syncthing
  ];

  # GUI apps, installed system-wide on NixOS only.
  desktop = with pkgs; [
    wezterm
    gimp
    drawio
    # Handy (speech-to-text) and Snapmaker Orca are not packaged; see native/.
  ];
  desktopPersonal = [ ]; # steam is enabled in nixos/default.nix instead
  desktopWork = with pkgs; [ mysql-workbench ];

  # forProfile / desktopForProfile: pick the lists for "personal" or "work".
  forProfile = profile: base ++ (if profile == "work" then work else personal);
  desktopForProfile = profile:
    desktop ++ (if profile == "work" then desktopWork else desktopPersonal);
}
