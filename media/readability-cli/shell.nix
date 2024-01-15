{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = [
    pkgs.nodePackages.node2nix
  ];

  shellHook = ''
    node2nix -18 -i npm-packages.json -c composition.nix
  '';
}
