{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yamlfmt
    vscode-langservers-extracted # Primarily for the JSON server
    nil # Nix

    # AI frontends
    claude-code
  ];
}
