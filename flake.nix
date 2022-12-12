{
  inputs = {
    nixpkgs.url = "nixpkgs";
    unstable.url = "nixpkgs/nixos-unstable";
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
    ...
  }: let
    clientSystem = "x86_64-linux";

    pkgs = nixpkgs.legacyPackages.${clientSystem};
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
