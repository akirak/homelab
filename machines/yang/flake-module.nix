{ inputs, ... }:
let
  channel = inputs.unstable;
in
{
  flake = {
    nixosConfigurations.yang = channel.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        hostPubkey = inputs.self.lib.hostPubkeys.yang;
      };

      modules = [
        ./.
        inputs.self.nixosModules.default
        {
          networking.hostName = "yang";
        }
      ];
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        # Provide caddy and certutils to install certificates from caddy
        # into the root store
        caddy = pkgs.mkShell {
          buildInputs = [
            pkgs.caddy
            pkgs.nssTools # certutils
          ];
        };
      };
    };
}
