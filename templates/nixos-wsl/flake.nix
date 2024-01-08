{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    emacs-config = {
      url = "github:akirak/emacs-config/develop";
      inputs.flake-pins.follows = "flake-pins";
    };
    flake-pins.url = "github:akirak/flake-pins";
    homelab.url = "github:akirak/homelab";
  };

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];

      flake = {
        nixosConfigurations = {
          wsl-private = inputs.homelab.lib.mkSystem (throw "Set the host name") {
            system = "x86_64-linux";
            channel = nixpkgs;
            specialArgs = {
              homeUser = throw "Set the user name";
              inherit (inputs) emacs-config;
            };
            extraModules = [
              # Mandatory settings for NixOS-WSL
              (inputs.nixos-wsl.outPath + "/modules")
              ({homeUser, ...}: {
                wsl.enable = true;
                wsl.defaultUser = homeUser;
                system.stateVersion = "23.11";
              })

              inputs.home-manager.nixosModules.home-manager
              inputs.homelab.nixosModules.hmProfile

              # My custom settings
              ({homeUser, ...}: {
                home-manager.users.${homeUser} = {
                  imports = [
                    (inputs.homelab.outPath + "/hm/basic.nix")
                  ];

                  home.username = homeUser;
                  home.homeDirectory = "/home/${homeUser}";
                  home.stateVersion = "23.11";

                  programs.emacs-twist = {
                    enable = true;
                    serviceIntegration.enable = true;
                    settings = {
                      extraFeatures = [
                      ];
                    };
                  };
                };
              })
            ];
          };
        };
      };
    };
}
