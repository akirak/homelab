{
  config,
  pkgs,
  lib,
  ...
}: let
  enableRecoll = config.services.recoll.enable;
  enableDirenv = config.programs.direnv.enable;
  enableGraphical = true;
  fontPackages = with pkgs; [
    cascadia-code
    inter
    source-han-sans
    noto-fonts-emoji
    symbola
    # Japanese
    ipafont
  ];
  enableWayland = enableGraphical;
  enableFoot = config.programs.foot.enable;
in {
  imports = import ./modules.nix {inherit lib;};

  programs = {
    bat.enable = true;
    exa.enable = true;
    exa.enableAliases = true;
    git.enable = true; # ./modules/git.nix
    gpg.enable = true; # ./modules/gpg.nix
    nix-index.enable = true;
    nix-index.enableZshIntegration = config.programs.nix-index.enable;
    direnv.enable = true; # ./modules/direnv.nix
    direnv.nix-direnv.enable = lib.mkIf enableDirenv true;
    # alacritty.enable = enableGraphical;
    mpv.enable = enableGraphical;
    firefox.enable = enableGraphical;
    foot.enable = enableWayland;
    foot.server.enable = enableFoot;
    # TODO: Add font package
    # foot.settings.main.font = "JetBrainsMono NF:size=10.5";
  };

  services = {
    recoll.enable = true;
    recoll.settings.followLinks = lib.mkIf enableRecoll true;
    syncthing.enable = true;
  };

  home.packages = with pkgs;
    [
      # Utilities
      ripgrep
      fd
      jq

      # Nix
      cachix
      nix-prefetch-git
      manix

      # Development
      gh
      pre-commit

      # squasher
      # drawio
      # emacsclient
      # hunspellDicts.en_US

      # Media
      git-annex

      # System
      glances
      du-dust
      duf

      # Net
      xh
      rclone
    ]
    ++ lib.optionals enableGraphical ([pkgs.blanket] ++ fontPackages);
}
