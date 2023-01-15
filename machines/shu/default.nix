{
  imports = [
    ../../suites/hcloud-remote.nix
    ../../suites/base.nix
    ../../profiles/tailscale.nix
    ../../profiles/nginx.nix
  ];

  networking.hostName = "shu";
  system.stateVersion = "22.11";
  time.timeZone = "America/Los_Angeles";

  disko.devices = import ./disko.nix {};

  nix.allowedUsers = ["root"];
}
