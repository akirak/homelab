{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-utils.url = "flake-utils";

  inputs.node2nix = {
    # url = "github:svanderburg/node2nix";
    url = "github:akirak/node2nix/develop";
    flake = false;
  };

  # Pinned packages from flakes
  inputs = {
    epubinfo.url = "github:akirak/epubinfo";
    epubinfo.inputs.flake-utils.follows = "flake-utils";
    squasher.url = "github:akirak/squasher";
  };

  # zsh plugins
  inputs = {
    zsh-fast-syntax-highlighting = {
      url = "github:zdharma-continuum/fast-syntax-highlighting";
      flake = false;
    };
    zsh-nix-shell = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
    };
    zsh-fzy = {
      url = "github:aperezdc/zsh-fzy";
      flake = false;
    };
    zsh-history-filter = {
      url = "github:MichaelAquilina/zsh-history-filter";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://akirak.cachix.org"
    ];
    extra-trusted-public-keys = [
      "akirak.cachix.org-1:WJrEMdV1dYyALkOdp/kAECVZ6nAODY5URN05ITFHC+M="
    ];
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }: let

    makePackages = pkgs: {
      # Override node2nix
      node2nix =
        (import inputs.node2nix {
          inherit pkgs;
          inherit (pkgs) system;
        })
          .package;

      github-linguist = pkgs.callPackage ./development/github-linguist {};

      shippori-mincho = pkgs.callPackage ./fonts/shippori-mincho.nix {};
      jetbrains-mono-nerdfont = pkgs.callPackage ./fonts/jetbrains-mono-nerdfont.nix {};


      wordnet-sqlite = pkgs.callPackage ./data/wordnet/wordnet-sqlite {};

      readability-cli = pkgs.callPackage ./media/readability-cli {inherit pkgs;};

      mermaid-cli = pkgs.nodePackages.mermaid-cli.overrideAttrs (_: {
        meta.mainProgram = "/bin/mmdc";
      });

      inherit (inputs.epubinfo.packages.${pkgs.system}) epubinfo;
      inherit (inputs.squasher.packages.${pkgs.system}) squasher;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        packages = makePackages pkgs;
      };
      flake = {
        overlays.default = final: _prev: makePackages final;
        zsh-plugins =
          nixpkgs.lib.genAttrs
          [
            "zsh-fzy"
            "zsh-nix-shell"
            "zsh-fast-syntax-highlighting"
            "zsh-history-filter"
          ]
          (name: inputs.${name}.outPath);
      };
    };
}
