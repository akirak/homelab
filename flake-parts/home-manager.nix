{ inputs, ... }:
{
  flake = {
    nixosModules = {
      hmProfile = {
        nixpkgs.overlays = [ inputs.self.overlays.default ];
        imports = [
          # Use a home-manager channel corresponding to your OS
          # inputs.home-manager.nixosModules.home-manager
          inputs.self.nixosModules.twistHomeModule
          ../nixos/profiles/home-manager
        ];
      };
    };
  };
}
