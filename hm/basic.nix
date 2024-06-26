{
  config,
  pkgs,
  ...
}: {
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

    # Media
    git-annex

    # System
    btop
    dua
    duf

    # Net
    xh
    rclone
    nmap
    tcpdump
  ];

  services = {
    recoll.enable = true;
    syncthing.enable = true;
  };
}
