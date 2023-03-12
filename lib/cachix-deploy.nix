{
  # From inputs
  self,
  cachix-deploy-flake,
  # Specific to the system
  pkgs,
  lib ? pkgs.lib,
  # Configuration
  nixosHosts ? [],
  homeHosts ? [],
}: let
  cachix-deploy-lib = cachix-deploy-flake.lib pkgs;
in
  cachix-deploy-lib.spec {
    agents =
      (lib.genAttrs nixosHosts (
        name:
          self.nixosConfigurations.${name}.config.system.build.toplevel
      ))
      // (
        lib.genAttrs homeHosts (
          name:
            self.homeConfigurations.${name}.activationPackage
        )
      );
  }
