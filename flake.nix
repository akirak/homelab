{
  inputs = {
    # From the registry
    nixpkgs.url = "stable";
    unstable.url = "unstable";
    home-manager.url = "home-manager";
    nix-darwin.url = "nix-darwin";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachix-deploy-flake = {
      url = "github:cachix/cachix-deploy-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "nix-darwin";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    unstable,
    flake-parts,
    nixos-generators,
    ...
  } @ inputs: let
    overlayModule = {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = unstable.legacyPackages.${prev.system};
        })
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages.cachix-deploys = import ./lib/cachix-deploy.nix {
          inherit pkgs;
          inherit (inputs) self cachix-deploy-flake;
          nixosHosts = ["shu"];
        };

        packages.rpi-bootstrap-sd-image = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            ./machines/zhuang/initial.nix
          ];
        };

        packages.asus-br1100-iso = (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            overlayModule
            self.nixosModules.asus-br1100
            ./suites/iso
          ];
        }).config.system.build.isoImage;
      };

      flake = {
        nixosConfigurations = {
          shu = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              overlayModule
              # You cannot add disko module to the root module list of
              # flake-parts. It causes infinite recursion.
              inputs.disko.nixosModules.disko
              ./machines/shu
            ];
          };

          # zhuang = nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   modules = [
          #     overlayModule
          #     # <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
          #     # inputs.disko.nixosModules.disko
          #     ./machines/zhuang/initial.nix
          #     ./machines/zhuang/rest.nix
          #   ];
          # };

        };

        diskoConfigurations = {
          shu = import ./machines/shu/disko.nix;
        };

        nixosModules = {
          asus-br1100 = import ./modules/models/asus-br1100.nix {
            inherit (inputs) nixos-hardware;
          };
        };
      };
    };
}
