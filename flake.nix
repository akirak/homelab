{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    ...
  }: let
    clientSystem = "x86_64-linux";

    pkgs = import nixpkgs {
      system = clientSystem;
    };
  in {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = clientSystem;
          overlays = [];
        };
      };

      zhuang = {
        deployment = {
          # A fixed IP address is configured in the router
          targetHost = "192.168.0.60";
          targetPort = 22;
          targetUser = "root";
        };
        nixpkgs.system = "aarch64-linux";
        imports = [
          <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
          ./config/zhuang/initial.nix
        ];
      };
    };

    packages.${clientSystem} = {
      # Use nixos-generators to bootstrap
      zhuang = nixos-generators.nixosGenerate {
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
