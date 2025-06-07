/*
Configuration for Windows Subsystem for Linux (WSL) with WSLg
*/
{pkgs, ...}: {
  home.packages = [
    pkgs.blanket
  ];

  programs.wslu.enable = true;
}
