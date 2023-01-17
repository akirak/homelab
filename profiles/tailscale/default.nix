{ pkgs, config, ... }:
let
  cfg = config.services.tailscale;
in
{
  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    checkReversePath = "loose";

    allowedTCPPorts = [
      cfg.port
    ];
  };
}
