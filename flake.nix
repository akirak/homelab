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
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

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

    nix-index-database.url = "github:Mic92/nix-index-database";

    my-overlay.url = "github:akirak/nixpkgs-overlay";
    emacs-config = {
      url = "github:akirak/emacs-config/develop";
      inputs.twist.follows = "twist";
    };
    twist.url = "github:emacs-twist/twist.nix";
  };

  nixConfig = {
    registry = "https://raw.githubusercontent.com/akirak/flake-pins/master/registry.json";
    extra-substituters = [
      "https://microvm.cachix.org"
      "https://cachix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
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

    overlays = [
      (final: prev: {
        unstable = unstable.legacyPackages.${prev.system};
        disko = inputs.disko.packages.${prev.system}.disko;
        zsh-plugins = inputs.my-overlay.zsh-plugins;
        inherit (unstable.legacyPackages.${prev.system}) cachix;
        nix-index = inputs.nix-index-database.packages.${prev.system}.nix-index-with-db;
      })
      inputs.my-overlay.overlays.default
    ];

    overlayModule = {
      nixpkgs.overlays = overlays;
    };

    twistHomeModule = {homeUser, ...}: {
      home-manager.users.${homeUser} = {
        imports = [
          inputs.emacs-config.homeModules.twist
        ];
      };
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
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

        mission-control.banner = ''
          echo "(Run , to show help)"
        '';
        mission-control.scripts = {
          check-format = {
            description = "Check syntax formatting; Fail if inconsistent";
            exec = "treefmt --fail-on-change";
          };
          deploy = {
            description = "Deploy to a host (requires root login via SSH)";
            exec = ''
              function deploy_to_host() {
                host="$1"
                nixos-rebuild switch --target-host "root@$host" --flake ".#$host" \
                  --use-remote-sudo --print-build-logs --option accept-flake-config true
              }
              if [[ $# -eq 0 ]]
              then
                echo -n "Please specify one of: "
                nix eval .#nixosConfigurations --apply builtins.attrNames \
                  --accept-flake-config 2>/dev/null
                exit 1
              fi
              for host; do
                if ping -c 1 "$host" > /dev/null
                then
                  deploy_to_host "$host"
                else
                  echo "$host is offline"
                fi
              done
            '';
          };
        };

        packages.launch-desktop-vm = self.lib.makeMicroVMSystem "demo-microvm" {
          inherit system;
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

        devShells.default =
          config.mission-control.installToDevShell
          (pkgs.mkShell {
            nativeBuildInputs = [
              config.treefmt.build.wrapper
            ];
          });
      };

      flake = {
        packages.x86_64-linux = {
          cachix-deploys = import ./lib/cachix-deploy.nix {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            inherit (inputs) self cachix-deploy-flake;
            nixosHosts = [
              # "shu"
              "hui"
            ];
            homeHosts = [
              "voyage"
            ];
          };

          asus-br1100-iso =
            (nixpkgs.lib.nixosSystem
              {
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
        };

        packages.aarch64-linux = {
          cachix-deploys = import ./lib/cachix-deploy.nix {
            pkgs = nixpkgs.legacyPackages.aarch64-linux;
            inherit (inputs) self cachix-deploy-flake;
            nixosHosts = [
              "zheng"
            ];
          };

          bootstrap-sd-image =
            (nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [
                overlayModule
                ({modulesPath, ...}: {
                  imports = [
                    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
                  ];
                })
                ./suites/installer
                {
                  networking.networkmanager.enable = true;
                }
              ];
            })
            .config
            .system
            .build
            .sdImage;
        };

        nixosConfigurations = builtins.mapAttrs self.lib.mkSystem {
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
          li = {
            system = "x86_64-linux";
            channel = unstable;
            specialArgs = {
              homeUser = "akirakomamura";
              inherit (inputs) emacs-config;
            };
            extraModules = [
              twistHomeModule
            ];
          };
          zheng = {
            system = "aarch64-linux";
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
          zheng = import ./machines/zheng/disko.nix;
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

        homeConfigurations = {
          voyage = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              inherit overlays;
              config = {
                allowUnfreePredicate = pkg:
                  builtins.elem (lib.getName pkg) [
                    "symbola"
                  ];
              };
            };
            extraSpecialArgs = {
              homeUser = "akirak";
            };
            modules = [
              ./machines/voyage/home.nix
              inputs.emacs-config.homeModules.twist
            ];
          };
        };

        templates = {
          home-manager = {
            path = ./templates/home-manager;
            description = "An example configuration repository for home-manager";
          };
        };

        lib = {
          /*
          Build a NixOS system with the modules.
          */
          mkSystem = hostName: {
            system,
            channel ? inputs.nixpkgs,
            specialArgs ? {},
            extraModules ? [],
          }: let
            machinePath = ./machines + "/${hostName}";

            configurationRevision =
              (builtins.substring 0 8 self.lastModifiedDate)
              + (
                if self ? rev
                then "." + builtins.substring 0 7 self.rev
                else "-emacs${
                  builtins.substring 0 8 inputs.emacs-config.lastModifiedDate
                }.${
                  if inputs.emacs-config ? rev
                  then builtins.substring 0 7 inputs.emacs-config.rev
                  else "dirty"
                }"
              );
          in
            channel.lib.nixosSystem {
              inherit system specialArgs;
              modules =
                [
                  {
                    networking.hostName = hostName;

                    system.configurationRevision =
                      nixpkgs.lib.mkIf (self ? lastModifiedDate) configurationRevision;
                  }
                  overlayModule
                  inputs.disko.nixosModules.disko
                  inputs.home-manager.nixosModules.home-manager
                  inputs.impermanence.nixosModules.impermanence
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
