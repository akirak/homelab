{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-utils.url = "flake-utils";
  inputs.cachix-push.url = "github:juspay/cachix-push";

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
    self,
    nixpkgs,
    flake-parts,
    ...
  }: let
    overlay = final: prev: {
      # Override node2nix
      node2nix =
        (import inputs.node2nix {
          pkgs = final;
          inherit (final) system;
        })
        .package;

      github-linguist = final.callPackage ./development/github-linguist {};

      shippori-mincho = final.callPackage ./fonts/shippori-mincho.nix {};
      jetbrains-mono-nerdfont = final.callPackage ./fonts/jetbrains-mono-nerdfont.nix {};

      wordnet-sqlite = final.callPackage ./data/wordnet/wordnet-sqlite {};

      inherit (inputs.epubinfo.packages.${prev.system}) epubinfo;
      inherit (inputs.squasher.packages.${prev.system}) squasher;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      imports = [
        inputs.cachix-push.flakeModule
      ];
      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages =
          nixpkgs.lib.getAttrs [
            "node2nix"
            "github-linguist"
            "shippori-mincho"
            "jetbrains-mono-nerdfont"
            "wordnet-sqlite"
            "epubinfo"
            "squasher"
          ] (import nixpkgs {
            inherit system;
            overlays = [
              overlay
            ];
          });
        apps.update-node2nix = {
          type = "app";
          program = "${pkgs.writeShellScript "run-node2nix" ''
            set -euo pipefail
            cd "generate/node2nix"
            ${self.packages.${system}.node2nix}/bin/node2nix -i node-packages.json -20
          ''}";
        };
        cachix-push = {
          cacheName = "akirak";
        };
      };
      flake = {
        overlays.default = overlay;
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
