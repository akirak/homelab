{
  imports = [
    ../../suites/hcloud-remote
    ../../suites/base
    ../../profiles/tailscale
    ../../profiles/nginx
    ../../profiles/nix/cachix-deploy.nix
    ./boot.nix
  ];

  system.stateVersion = "23.05";
  networking.hostId = "9bc2dd3d";
  time.timeZone = "America/Los_Angeles";

  disko.devices = import ./disko.nix {};

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';
}
