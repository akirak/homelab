{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    unstable,
    nixos-generators,
    nix-on-droid,
    home-manager,
    ...
  }: let
    clientSystem = "x86_64-linux";

    pkgs = nixpkgs.legacyPackages.${clientSystem};

    droidPkgs = import nixpkgs {
      system = "aarch64-linux";
      overlays = [
        nix-on-droid.overlays.default
      ];
    };

    mkDroidConfiguration = {modules}:
      nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = droidPkgs;
        home-manager-path = home-manager.outPath;
        # extraSpecialArgs = { };
        modules =
          [
            {
              system.stateVersion = "22.11";
              # Minimize the number of nixpkgs instance
              home-manager.useGlobalPkgs = true;
            }
          ]
          ++ modules;
      };
  in {
    colmena = {
      meta = {
        nixpkgs = pkgs;
        specialArgs = {
          inherit unstable;
        };
      };

      zhuang = {
        deployment = {
          # A fixed IP address is configured in the router
          targetHost = "192.168.0.60";
          targetPort = 2022;
          targetUser = "root";
        };
        nixpkgs.system = "aarch64-linux";
        imports = [
          <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
          ./config/zhuang/initial.nix
          ./config/zhuang/rest.nix
        ];
      };
    };

    nixOnDroidConfigurations = {
      default = mkDroidConfiguration {
        modules = [
          {
            environment.etcBackupExtension = ".bak";
            environment.packages = with pkgs; [
              emacs
              git
            ];
          }
        ];
      };
    };

    packages.${clientSystem} = {
      # Use nixos-generators to bootstrap
      sd-image-zhuang = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          ./config/zhuang/initial.nix
        ];
      };
    };

    devShells.${clientSystem} = {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.colmena
        ];
      };
    };
  };
}
