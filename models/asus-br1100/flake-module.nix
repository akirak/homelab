{ inputs, ... }:
let
  inherit (inputs) stable;

  overlayModule = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
in
{
  flake = {
    nixosModules = {
      asus-br1100 = import ./modules { inherit (inputs) nixos-hardware; };
    };

    packages.x86_64-linux = {
      asus-br1100-iso =
        (stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            overlayModule
            inputs.self.nixosModules.asus-br1100
            ../../suites/iso
          ];
        }).config.system.build.isoImage;
    };
  };
}
