{
  inputs = {
    # From the registry
    nixpkgs.url = "stable";
    unstable.url = "unstable";
    home-manager.url = "home-manager";
    nix-darwin.url = "nix-darwin";
    flake-utils.url = "flake-utils";

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

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.flake-utils.follows = "flake-utils";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    registry = "https://raw.githubusercontent.com/akirak/flake-pins/master/registry.json";
    extra-substituters = [
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    flake-parts,
    nixos-generators,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    overlayModule = {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = unstable.legacyPackages.${prev.system};
          disko = inputs.disko.packages.${prev.system}.disko;
        })
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
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
        treefmt = {
          projectRootFile = "flake.nix";
          package = pkgs.treefmt;
          programs.alejandra.enable = true;
        };

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

        packages.asus-br1100-iso =
          (nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              overlayModule
              inputs.self.nixosModules.asus-br1100
              ./suites/iso
            ];
          })
          .config
          .system
          .build
          .isoImage;

        packages.launch-desktop-vm = let
          inherit
            (nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                hypervisor = "qemu";
                homeUser = "root";
              };
              modules = [
                overlayModule
                inputs.microvm.nixosModules.microvm
                ./suites/microvm-gui
                ./profiles/desktop/plasma.nix
                inputs.home-manager.nixosModules.home-manager
                ./profiles/home-manager
              ];
            })
            config
            ;
        in
          config.microvm.runner.${config.microvm.hypervisor};

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            config.treefmt.build.wrapper
          ];
        };
      };

      flake = {
        nixosConfigurations = let
          mkSystem = hostName: {
            system,
            specialArgs ? {},
            extraModules ? [],
          }:
            nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules =
                [
                  overlayModule
                  {
                    # Let 'nixos-version --json' know about the Git revision of this
                    # flake.
                    system.configurationRevision =
                      if self ? lastModifiedDate && self ? rev
                      then "${self.lastModifiedDate}-${self.rev}"
                      else if self ? rev
                      then self.rev
                      else null;
                  }
                  inputs.disko.nixosModules.disko
                  inputs.home-manager.nixosModules.home-manager
                  (./machines + "/${hostName}")
                ]
                ++ extraModules;
            };
        in
          builtins.mapAttrs mkSystem {
            shu = {
              system = "x86_64-linux";
            };
            hui = {
              system = "x86_64-linux";
              specialArgs = {
                homeUser = "akirakomamura";
              };
              extraModules = [
                inputs.self.nixosModules.asus-br1100
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
          hui = import ./machines/hui/disko.nix;
        };

        nixosModules = {
          asus-br1100 = import ./modules/models/asus-br1100 {
            inherit (inputs) nixos-hardware;
          };
        };
      };
    };
}
