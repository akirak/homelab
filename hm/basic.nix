{ config, pkgs, ... }:
{
  programs = {
    nix-index.enable = true;
    nix-index.enableZshIntegration = config.programs.nix-index.enable;
    password-store.enable = true;
  };

  home.packages = with pkgs; [
    # Nix
    nix-prefetch-git
    nix-output-monitor

    # Development
    gh
    difftastic
    duckdb
    tbls
    hyperfine
    just
    tailspin

    # Media
    git-annex

    # System
    btop
    dua
    duf

    # Net
    xh
  ];

  services = {
    recoll.enable = true;
    syncthing.enable = true;
  };
}
