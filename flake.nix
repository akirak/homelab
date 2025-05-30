{
  inputs = {
    flake-pins.url = "github:akirak/flake-pins";

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # More frequently input to use the newer versions of packages.
    unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-unstable.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager-stable.inputs.nixpkgs.follows = "stable";
    home-manager-unstable.inputs.nixpkgs.follows = "unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };

    impermanence.url = "github:nix-community/impermanence";

    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "unstable";

    # cachix-deploy-flake = {
    #   url = "github:cachix/cachix-deploy-flake";
    #   inputs.nixpkgs.follows = "stable";
    #   inputs.home-manager.follows = "home-manager-stable";
    #   inputs.darwin.follows = "nix-darwin";
    # };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "unstable";
    };

    hyprland-contrib.url = "github:hyprwm/contrib";

    emacs-config = {
      url = "github:akirak/emacs-config/develop";
      inputs.twist.follows = "twist";
    };
    twist.url = "github:emacs-twist/twist.nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://hyprland.cachix.org"
      "https://akirak.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "akirak.cachix.org-1:WJrEMdV1dYyALkOdp/kAECVZ6nAODY5URN05ITFHC+M="
    ];
  };

  outputs =
    {
      self,
      stable,
      unstable,
      flake-parts,
      flake-pins,
      ...
    }@inputs:
    let
      inherit (stable) lib;

      overlays = [
        inputs.flake-pins.overlays.default
        (_final: prev: {
          channels = lib.genAttrs [
            "hyprland-contrib"
            "fonts"
            "zsh-plugins"
          ] (name: inputs.${name}.packages.${prev.system});
          unstable = unstable.legacyPackages.${prev.system};
          # Explicit import from the small nixpkgs.
          unstable-small-unfree = import inputs.unstable-small {
            inherit (prev) system;
            config.allowUnfree = true;
          };
          # unstable-small = inputs.unstable-small.legacyPackages.${prev.system};
          disko = inputs.disko.packages.${prev.system}.disko;
          nix-index = inputs.nix-index-database.packages.${prev.system}.nix-index-with-db;
        })
      ];

      overlayModule = {
        nixpkgs.overlays = overlays;
      };

      twistHomeModule =
        { homeUser, ... }:
        {
          home-manager.users.${homeUser} = {
            imports = [ inputs.emacs-config.homeModules.twist ];
          };
        };

      hostPubkeys = lib.pipe (lib.importTOML ./machines/metadata.toml).hosts [
        (lib.filterAttrs (_: attrs: attrs ? publicKey))
        (builtins.mapAttrs (_: attrs: attrs.publicKey))
      ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          treefmtEval,
          ...
        }:
        {
          _module.args.pkgs = unstable.legacyPackages.${system};
          _module.args.treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

          packages = lib.mapAttrs' (
            hostName: _:
            lib.nameValuePair "deploy-${hostName}" (
              pkgs.writeShellApplication {
                name = "deploy";
                runtimeInputs = [ stable.legacyPackages.${system}.nixos-rebuild ];
                meta.description = "A nixos-rebuild wrapper that targets a host on LAN";
                text = ''
                  target_host="${hostName}"

                  usage() {
                    echo "deploy [--target-host IP] switch|test ARGS"
                  }

                  while [[ $# -gt 0 ]]; do
                    case "$1" in
                      --help|-h)
                        usage
                        exit
                        ;;
                      --target-host)
                        target_host="$2"
                        shift; shift
                        ;;
                      *)
                        mode="$1"
                        shift
                        break
                        ;;
                    esac
                  done

                  if ! [[ -v mode ]]; then
                    echo >&2 "You need to specify one of the subcommands of nixos-rebuild"
                    exit 1
                  fi

                  set -x

                  # Don't look up known_hosts file because the host key is updated on every deploy
                  NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
                    nixos-rebuild "$mode" \
                    --flake ".#${hostName}" \
                    --target-host "root@''${target_host}" \
                    --option accept-flake-config true \
                    "$@"
                '';
              }
            )
          ) self.nixosConfigurations;

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                pkgs.age
                pkgs.age-plugin-yubikey
              ];
              nativeBuildInputs = [ inputs.agenix-rekey.packages.${system}.default ];
            };

            # Provide caddy and certutils to install certificates from caddy
            # into the root store
            caddy = pkgs.mkShell {
              buildInputs = [
                pkgs.caddy
                pkgs.nssTools # certutils
              ];
            };
          };

          formatter = treefmtEval.config.build.wrapper;

          checks.formatting = treefmtEval.config.build.check inputs.self;
        };

      flake = {
        packages.x86_64-linux = {
          # cachix-deploys = import ./lib/cachix-deploy.nix {
          #   pkgs = unstable.legacyPackages.x86_64-linux;
          #   inherit (inputs) self cachix-deploy-flake;
          #   nixosHosts = [
          #     # "shu"
          #     "hui"
          #   ];
          #   homeHosts = [
          #     # "voyage"
          #   ];
          # };

          remote-installer-image =
            (stable.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                overlayModule
                ./suites/remote-installer
                (
                  { modulesPath, ... }:
                  {
                    imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];
                  }
                )
              ];
            }).config.system.build.isoImage;

          asus-br1100-iso =
            (stable.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                overlayModule
                inputs.self.nixosModules.asus-br1100
                ./suites/iso
              ];
            }).config.system.build.isoImage;
        };

        packages.aarch64-linux = {
          # cachix-deploys = import ./lib/cachix-deploy.nix {
          #   pkgs = unstable.legacyPackages.aarch64-linux;
          #   inherit (inputs) self cachix-deploy-flake;
          #   nixosHosts = [ "zheng" ];
          # };

          bootstrap-sd-image =
            (unstable.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [
                overlayModule
                (
                  { modulesPath, ... }:
                  {
                    imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];
                  }
                )
                ./suites/installer
                { networking.networkmanager.enable = true; }
              ];
            }).config.system.build.sdImage;
        };

        nixosConfigurations = builtins.mapAttrs self.lib.mkSystem {
          shu = {
            system = "x86_64-linux";
            channel = stable;
          };
          yang = {
            system = "x86_64-linux";
            channel = unstable;
          };
          wang = {
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
              inputs.nixos-hardware.nixosModules.common-gpu-intel
              twistHomeModule
            ];
          };

          zheng = {
            system = "aarch64-linux";
            channel = stable;
            extraModules = [ (stable + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix") ];
          };
        };

        diskoConfigurations = {
          shu = import ./machines/shu/disko.nix;
        };

        nixosModules = {
          asus-br1100 = import ./modules/models/asus-br1100 { inherit (inputs) nixos-hardware; };
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
          # voyage = inputs.home-manager.lib.homeManagerConfiguration {
          #   pkgs = import unstable {
          #     system = "x86_64-linux";
          #     inherit overlays;
          #     config = {
          #       allowUnfreePredicate = pkg:
          #         builtins.elem (lib.getName pkg) [
          #           "symbola"
          #         ];
          #     };
          #   };
          #   extraSpecialArgs = {
          #     homeUser = "akirak";
          #   };
          #   modules = [
          #     ./machines/voyage/home.nix
          #     inputs.emacs-config.homeModules.twist
          #   ];
          # };
        };

        agenix-rekey = inputs.agenix-rekey.configure {
          userFlake = self;
          nixosConfigurations = builtins.intersectAttrs hostPubkeys self.nixosConfigurations;
        };

        templates = {
          home-manager = {
            path = ./templates/home-manager;
            description = "An example configuration repository for home-manager";
          };
          nixos-wsl = {
            path = ./templates/nixos-wsl;
            description = "An example configuration flake for NixOS-WSL";
          };
        };

        lib = {
          # Build a NixOS system with the modules.
          mkSystem =
            hostName:
            {
              system,
              # If you are using this function from outside this repository,
              # override this argument with your own inputs.self.
              self' ? inputs.self,
              channel ? inputs.stable,
              specialArgs ? { },
              extraModules ? [ ],
            }:
            let
              machinePath = ./machines + "/${hostName}";

              configurationRevision = "${builtins.substring 0 8 self'.lastModifiedDate}.${self'.rev or "dirty"}";

              hostPubkey = hostPubkeys.${hostName} or null;
            in
            channel.lib.nixosSystem {
              inherit system specialArgs;
              modules =
                [
                  {
                    networking.hostName = hostName;

                    system.configurationRevision = channel.lib.mkIf (self' ? lastModifiedDate) configurationRevision;
                  }
                  overlayModule
                  inputs.disko.nixosModules.disko
                  inputs.impermanence.nixosModules.impermanence
                  ./modules/services/livebook
                  {
                    nix.registry = lib.pipe (lib.importJSON (flake-pins + "/registry.json")).flakes [
                      (map ({ from, to }: lib.nameValuePair from.id { inherit from to; }))
                      lib.listToAttrs
                    ];
                  }
                ]
                ++ lib.optionals (hostPubkey != null) [
                  inputs.agenix.nixosModules.default
                  inputs.agenix-rekey.nixosModules.default
                  # You have to define these options for every host.
                  {
                    age.rekey = {
                      inherit hostPubkey;
                      masterIdentities = [ ./secrets/yubikey.pub ];
                      storageMode = "local";
                      localStorageDir = ./. + "/secrets/rekeyed/${hostName}";
                      # TODO: Add backup keys
                      # extraEncryptionPubkeys = [];
                    };
                  }
                ]
                ++ lib.optional (builtins.pathExists machinePath) machinePath
                ++ extraModules;
            };
        };
      };
    };
}
