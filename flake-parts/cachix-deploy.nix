# Currently unused
{ lib, inputs, ... }:
let
  inherit (inputs) self;

  nixosHosts = [
    "hui"
  ];

  homeHosts = [
  ];
in
{
  flake = {
    packages.x86_64-linux =
      let
        pkgs = inputs.unstable.legacyPackages.x86_64-linux;
      in
      {
        cachix-deploys = (inputs.cachix-deploy-flake.lib pkgs).spec {
          agents =
            (lib.genAttrs nixosHosts (name: self.nixosConfigurations.${name}.config.system.build.toplevel))
            // (lib.genAttrs homeHosts (name: self.homeConfigurations.${name}.activationPackage));
        };
      };
  };
}
