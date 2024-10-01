{ config, pkgs, ... }:
{
  programs = {
    nix-index.enable = true;
    nix-index.enableZshIntegration = config.programs.nix-index.enable;
  };

  home.packages = with pkgs; [
    # Nix
    nix-prefetch-git

    # Tools
    pv

    # Development
    gh
    pre-commit
    alejandra
    difftastic
    duckdb
    tbls
    hyperfine
    just
    yamlfmt
    vscode-langservers-extracted # Primarily for the JSON server
    nil # Nix

    # Media
    git-annex

    # System
    btop
    dua
    duf

    # Net
    xh
  ];

  programs.rbw.enable = true;

  services = {
    recoll.enable = true;
    syncthing.enable = true;
  };
}
