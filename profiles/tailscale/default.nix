{ pkgs, config, unstable, ... }:
let
  unstablePkgs = unstable.legacyPackages.${config.nixpkgs.system};
  cfg = config.services.tailscale;
in
{
  services.tailscale = {
    enable = true;
    package = unstablePkgs.tailscale;
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    checkReversePath = "loose";

    allowedTCPPorts = [
      cfg.port
    ];
  };
}
