{ inputs, ... }:
let
  channel = inputs.stable;
in
{
  flake = {
    nixosConfigurations.wang = channel.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        hostPubkey = null;
      };

      modules = [
        ./.
        inputs.self.nixosModules.default
        {
          networking.hostName = "wang";
        }
      ];
    };
  };
}
