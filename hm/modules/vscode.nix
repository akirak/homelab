{ pkgs, ... }:
{
  programs.vscode = {
    package = pkgs.windsurf;
  };
}
