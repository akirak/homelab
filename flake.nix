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
    self,
    nixpkgs,
    flake-parts,
    ...
  }: let
    overlay = final: prev:
      let
      nodePackages =
        import ./generate/node2nix {
          pkgs = final;
          inherit (prev) system;
          nodejs = final.nodejs_latest;
        };
      in
      {
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

      readability-cli = prev.callPackage ./media/readability-cli {pkgs = prev;};

      mermaid-cli = prev.nodePackages.mermaid-cli.overrideAttrs (_: {
        meta.mainProgram = "/bin/mmdc";
      });

      ajv = nodePackages.ajv-cli.overrideAttrs (_: {
        meta.mainProgram = "ajv";
      });

      inherit (inputs.epubinfo.packages.${prev.system}) epubinfo;
      inherit (inputs.squasher.packages.${prev.system}) squasher;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages = overlay pkgs pkgs;
        apps.update-node2nix = {
          type = "app";
          program = "${pkgs.writeShellScript "run-node2nix" ''
            set -euo pipefail
            cd "generate/node2nix"
            ${self.packages.${system}.node2nix}/bin/node2nix -i node-packages.json -20
          ''}";
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
