{ pkgs, ... }:
{
  programs.vscode = {
    package = pkgs.code-cursor;
  };
}
