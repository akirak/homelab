{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";

    flake-utils.url = "github:numtide/flake-utils";

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

    my-overlay.url = "github:akirak/nixpkgs-overlay";
    twist.url = "github:emacs-twist/twist.nix";
    emacs-config.url = "github:akirak/nix-config/develop";
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
          zsh-plugins = inputs.my-overlay.zsh-plugins;
        })
        inputs.my-overlay.overlays.default
      ];
    };

    twistHomeModule = {homeUser, ...}: {
      home-manager.users.${homeUser} = {
        imports = [
          inputs.twist.homeModules.emacs-twist
        ];
      };
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
          nixosHosts = [
            # "shu"
            "hui"
          ];
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

        packages.launch-desktop-vm = self.lib.makeMicroVMSystem "demo-microvm" {
          system = "x86_64-linux";
          specialArgs = {
            hypervisor = "qemu";
            homeUser = "root";
          };
          modules = [
            ./suites/microvm-gui
            ./profiles/desktop/plasma.nix
            ./profiles/home-manager
          ];
        };

        packages.launch-container = self.lib.makeMicroVMSystem "demo-microvm" {
          inherit system;
          specialArgs = {
            hypervisor = "qemu";
            homeUser = "root";
          };
          modules = [
            ./suites/microvm
          ];
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            config.treefmt.build.wrapper
          ];
        };
      };

      flake = {
        nixosConfigurations = let
          makeRevisionString = src:
            if src ? lastModifiedDate && src ? rev
            then "${src.lastModifiedDate}-${src.rev}"
            else if src ? rev
            then src.rev
            else null;
          mkSystem' = hostName: args @ {extraModules ? [], ...}:
            self.lib.mkSystem hostName (args
              // {
                extraModules =
                  extraModules
                  ++ [
                    {
                      # Set the version returned by `nixos-version --json' command
                      system.configurationRevision = makeRevisionString self;
                    }
                  ];
              });
        in
          builtins.mapAttrs mkSystem' {
            shu = {
              system = "x86_64-linux";
            };
            hui = {
              system = "x86_64-linux";
              specialArgs = {
                homeUser = "akirakomamura";
                inherit (inputs) emacs-config;
              };
              extraModules = [
                inputs.self.nixosModules.asus-br1100
                twistHomeModule
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
          hmProfile = {
            imports = [
              inputs.home-manager.nixosModules.home-manager
              overlayModule
              twistHomeModule
              ./profiles/home-manager
            ];
          };
        };

        lib = {
          /*
          Build a NixOS system with the modules.
          */
          mkSystem = hostName: {
            system,
            specialArgs ? {},
            extraModules ? [],
          }: let
            machinePath = ./machines + "/${hostName}";
          in
            nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules =
                [
                  {
                    networking.hostName = hostName;
                  }
                  overlayModule
                  inputs.disko.nixosModules.disko
                  inputs.home-manager.nixosModules.home-manager
                ]
                ++ lib.optional (builtins.pathExists machinePath) machinePath
                ++ extraModules;
            };

          makeMicroVMSystem = name: {
            system,
            specialArgs,
            modules,
          }: let
            inherit
              (self.lib.mkSystem name {
                inherit system specialArgs;
                extraModules =
                  [
                    inputs.microvm.nixosModules.microvm
                  ]
                  ++ modules;
              })
              config
              ;
          in
            config.microvm.runner.${config.microvm.hypervisor};
        };
      };
    };
}
