{ pkgs, lib, ... }:
{
  imports = import ./modules.nix { inherit lib; };

  programs = {
    bat.enable = true;
    git.enable = true;
    nix-index.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq

    cachix
    nix-prefetch-git
    manix

    glances
    du-dust
    duf

    xh
    rclone
  ];
}
