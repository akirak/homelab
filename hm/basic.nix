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
    nixd

    # Development
    gh
    pre-commit
    alejandra
    ast-grep

    # Media
    git-annex

    # System
    glances
    du-dust
    duf

    # Net
    xh
    rclone
  ];

  services = {
    recoll.enable = true;
    syncthing.enable = true;
    pueue.enable = true;
  };
}
