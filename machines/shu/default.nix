{
  imports = [
    ../../suites/hcloud-remote.nix
    ../../suites/base.nix
    ../../profiles/tailscale.nix
    ../../profiles/nginx.nix
    ./boot.nix
  ];

  networking.hostName = "shu";
  system.stateVersion = "22.11";
  networking.hostId = "9bc2dd3d";
  time.timeZone = "America/Los_Angeles";

  disko.devices = import ./disko.nix {};

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';
}
