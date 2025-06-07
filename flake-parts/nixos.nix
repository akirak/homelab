{ inputs, ... }:
let
  inherit (inputs) self flake-pins;
in
{
  flake = {
    nixosModules = {
      default =
        {
          # Explicitly pass as specialArg to prevent infinite recursion when
          # determining the modules to import
          hostPubkey,
          config,
          lib,
          ...
        }:
        let
          inherit (config.networking) hostName;
          configurationRevision = "${builtins.substring 0 8 self.lastModifiedDate}.${self.rev or "dirty"}";
          # hostPubkey = self.lib.hostPubkeys.${hostName} or null;
        in
        {
          system.configurationRevision = lib.mkIf (inputs.self ? lastModifiedDate) configurationRevision;
          nixpkgs.overlays = [ inputs.self.overlays.default ];

          imports =
            [
              inputs.disko.nixosModules.disko
              inputs.impermanence.nixosModules.impermanence
              ../modules/services/livebook
              flake-pins.nixosModules.nix-registry
            ]
            ++ lib.optionals (hostPubkey != null) [
              inputs.agenix.nixosModules.default
              inputs.agenix-rekey.nixosModules.default
              # You have to define these options for every host.
              {
                age.rekey = {
                  inherit hostPubkey;
                  masterIdentities = [ ../secrets/yubikey.pub ];
                  storageMode = "local";
                  localStorageDir = ../. + "/secrets/rekeyed/${hostName}";
                  # TODO: Add backup keys
                  # extraEncryptionPubkeys = [];
                };
              }
            ];
        };

    };
  };
}
