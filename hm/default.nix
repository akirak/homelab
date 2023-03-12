{lib, ...}: {
  imports = [
    ./core.nix
    ./basic.nix
    ./graphical.nix
  ];

  programs.vscode.enable = true;
}
