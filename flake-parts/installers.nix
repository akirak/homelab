{ inputs, ... }:
let
  inherit (inputs) stable unstable;

  overlayModule = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
in
{
  flake = {
    packages.x86_64-linux = {
      remote-installer-image =
        (stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            overlayModule
            ../suites/remote-installer
            (
              { modulesPath, ... }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];
              }
            )
          ];
        }).config.system.build.isoImage;
    };

    packages.aarch64-linux = {
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
            ../suites/installer
            { networking.networkmanager.enable = true; }
          ];
        }).config.system.build.sdImage;
    };
  };
}
