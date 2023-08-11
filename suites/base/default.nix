{
  self,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../profiles/openssh
  ];

  networking.firewall.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc.automatic = true;
  };
}
