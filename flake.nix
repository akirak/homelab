{
  inputs = {
    # From the registry
    nixpkgs.url = "stable";
    unstable.url = "unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

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
  } @ inputs:
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
        # Use nixos-generators to bootstrap
        packages.sd-image-zhuang = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            ./config/hosts/zhuang/initial.nix
          ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.colmena
          ];
        };
      };

      flake = {
        colmena = {
          meta = {
            nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
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
              ./config/hosts/zhuang/initial.nix
              ./config/hosts/zhuang/rest.nix
            ];
          };
        };
      };
    };
}
