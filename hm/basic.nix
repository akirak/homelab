{
  config,
  pkgs,
  ...
}: {
  programs = {
    nix-index.enable = true;
    nix-index.enableZshIntegration = config.programs.nix-index.enable;
    nushell.enable = true;
  };

  home.packages = with pkgs; [
    # Nix
    cachix
    nix-prefetch-git
    manix

    # Tools
    pv

    # Development
    gh
    pre-commit
    alejandra
    difftastic
    duckdb
    tbls

    # Media
    git-annex

    # System
    glances
    dua
    duf

    # Net
    httpie
    rclone
  ];

  services = {
    recoll.enable = true;
    syncthing.enable = true;
    pueue.enable = true;
  };
}
