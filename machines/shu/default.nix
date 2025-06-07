{
  imports = [
    ../../nixos/suites/hcloud-remote
    ../../nixos/suites/base
    ../../nixos/profiles/tailscale
    ../../nixos/profiles/nginx
    ../../nixos/profiles/nix/cachix-deploy.nix
    ./boot.nix
    (import ./disko.nix {})
  ];

  networking.hostId = "9bc2dd3d";
  time.timeZone = "America/Los_Angeles";

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';
}
