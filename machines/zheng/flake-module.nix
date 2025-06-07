{ inputs, ... }:
let
  channel = inputs.stable;
in
{
  flake = {
    nixosConfigurations.zheng = channel.lib.nixosSystem {
      system = "aarch64-linux";

      specialArgs = {
        hostPubkey = inputs.self.lib.hostPubkeys.zheng;
      };

      modules = [
        ./.
        inputs.self.nixosModules.default
        (channel + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
        {
          networking.hostName = "zheng";
        }
      ];
    };
  };
}
