{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager-stable.url = "github:nix-community/home-manager/release-23.05";
    home-manager-unstable.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager-stable.inputs.nixpkgs.follows = "stable";
    home-manager-unstable.inputs.nixpkgs.follows = "unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };

    impermanence.url = "github:nix-community/impermanence";

    cachix-deploy-flake = {
      url = "github:cachix/cachix-deploy-flake";
      inputs.nixpkgs.follows = "stable";
      inputs.disko.follows = "disko";
      inputs.home-manager.follows = "home-manager-stable";
      inputs.darwin.follows = "nix-darwin";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "stable";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.flake-utils.follows = "flake-utils";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    nix-index-database.url = "github:Mic92/nix-index-database";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";

    nixd.url = "github:nix-community/nixd";

    my-overlay.url = "github:akirak/nixpkgs-overlay";
    emacs-config = {
      url = "github:akirak/emacs-config/develop";
      inputs.twist.follows = "twist";
    };
    twist.url = "github:emacs-twist/twist.nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://microvm.cachix.org"
      "https://cachix.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  outputs = {
    self,
    stable,
    unstable,
    flake-parts,
    ...
  } @ inputs: let
    inherit (stable) lib;

    overlays = [
      (_final: prev: {
        channels = lib.genAttrs [
          "hyprland-contrib"
        ] (name: inputs.${name}.packages.${prev.system});
        unstable = unstable.legacyPackages.${prev.system};
        customPackages = {
          hyprland = inputs.hyprland.packages.${prev.system}.hyprland;
          waybar-hyprland = inputs.hyprland.packages.${prev.system}.waybar-hyprland;
        };
        disko = inputs.disko.packages.${prev.system}.disko;
        zsh-plugins = inputs.my-overlay.zsh-plugins;
        inherit (unstable.legacyPackages.${prev.system}) cachix;
        nix-index = inputs.nix-index-database.packages.${prev.system}.nix-index-with-db;
      })
      inputs.my-overlay.overlays.default
      inputs.nixd.overlays.default
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
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = unstable.legacyPackages.${system};

        treefmt = {
          projectRootFile = ".git/config";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            shellcheck.enable = true;
          };
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

        devShells.default = pkgs.mkShell {
          buildInputs = [
            self.formatter.${system}
          ];
          inputsFrom = [
            config.mission-control.devShell
          ];
        };
      };

      flake = {
        packages.x86_64-linux = {
          cachix-deploys = import ./lib/cachix-deploy.nix {
            pkgs = unstable.legacyPackages.x86_64-linux;
            inherit (inputs) self cachix-deploy-flake;
            nixosHosts = [
              # "shu"
              "hui"
            ];
            homeHosts = [
              # "voyage"
            ];
          };

          asus-br1100-iso =
            (stable.lib.nixosSystem
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

          # launch-desktop-vm = self.lib.makeMicroVMSystem "demo-microvm" {
          #   system = "x86_64-linux";
          #   channel = unstable;
          #   specialArgs = {
          #     hypervisor = "qemu";
          #     homeUser = "root";
          #   };
          #   modules = [
          #     inputs.home-manager-unstable.nixosModules.home-manager
          #     ./suites/microvm-gui
          #     ./profiles/desktop/plasma.nix
          #     ./profiles/home-manager
          #   ];
          # };

          launch-container = self.lib.makeMicroVMSystem "demo-microvm" {
            system = "x86_64-linux";
            specialArgs = {
              hypervisor = "qemu";
              homeUser = "root";
            };
            modules = [
              inputs.home-manager-unstable.nixosModules.home-manager
              ./suites/microvm
            ];
          };
        };

        packages.aarch64-linux = {
          cachix-deploys = import ./lib/cachix-deploy.nix {
            pkgs = unstable.legacyPackages.aarch64-linux;
            inherit (inputs) self cachix-deploy-flake;
            nixosHosts = [
              "zheng"
            ];
          };

          bootstrap-sd-image =
            (unstable.lib.nixosSystem {
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
            channel = stable;
          };
          hui = {
            system = "x86_64-linux";
            channel = unstable;
            specialArgs = {
              homeUser = "akirakomamura";
              inherit (inputs) emacs-config;
            };
            extraModules = [
              inputs.home-manager-unstable.nixosModules.home-manager
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
              inputs.home-manager-unstable.nixosModules.home-manager
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
              # Use a home-manager channel corresponding to your OS
              # inputs.home-manager.nixosModules.home-manager
              overlayModule
              twistHomeModule
              ./profiles/home-manager
            ];
          };
        };

        homeConfigurations = {
          voyage = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import unstable {
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
            channel ? inputs.stable,
            specialArgs ? {},
            extraModules ? [],
          }: let
            machinePath = ./machines + "/${hostName}";

            configurationRevision = "${builtins.substring 0 8 self.lastModifiedDate}.${
              if self ? rev
              then builtins.substring 0 7 self.rev
              else "dirty"
            }";
          in
            channel.lib.nixosSystem {
              inherit system specialArgs;
              modules =
                [
                  {
                    networking.hostName = hostName;

                    system.configurationRevision =
                      channel.lib.mkIf (self ? lastModifiedDate) configurationRevision;
                  }
                  overlayModule
                  inputs.disko.nixosModules.disko
                  inputs.impermanence.nixosModules.impermanence
                  inputs.hyprland.nixosModules.default
                  ./modules/services/livebook
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
