# Currently unused
{ inputs, ... }:
let
  inherit (inputs) unstable;
in
{
  flake = {
    packages.x86_64-linux = {
      cachix-deploys = import ./lib/cachix-deploy.nix {
        pkgs = unstable.legacyPackages.x86_64-linux;
        inherit (inputs) self cachix-deploy-flake;
        nixosHosts = [
          # "shu"
          "hui"
        ];
        homeHosts = [
          # "voyage"
        ];
      };
    };
  };
}
