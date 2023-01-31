{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs @ {flake-parts, ...}: let
    makePackages = pkgs: {
      github-linguist = pkgs.callPackage ./development/github-linguist {};

      shippori-mincho = pkgs.callPackage ./fonts/shippori-mincho.nix {};
      jetbrains-mono-nerdfont = pkgs.callPackage ./fonts/jetbrains-mono-nerdfont.nix {};

      wordnet-sqlite = pkgs.callPackage ./data/wordnet/wordnet-sqlite {};

      readability-cli = pkgs.callPackage ./media/readability-cli {inherit pkgs;};

      mermaid-cli = pkgs.nodePackages.mermaid-cli.overrideAttrs (_: {
        meta.mainProgram = "/bin/mmdc";
      });
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        packages = makePackages pkgs;
      };
      flake = {
        overlays.default = final: _prev: makePackages final;
      };
    };
}
