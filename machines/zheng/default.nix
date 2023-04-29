{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/headless.nix")
    ../../suites/server
    ../../profiles/tailscale
    # ../../profiles/nix/cachix-deploy.nix
    ./boot.nix
    (import ./disko.nix {})
  ];

  system.stateVersion = "22.11";
  time.timeZone = "Asia/Tokyo";

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';

  boot.cleanTmpDir = true;
  powerManagement.cpuFreqGovernor = "ondemand";
  zramSwap.enable = true;

  users.users.akirakomamura = {
    uid = 1000;
    isNormalUser = true;
  };

  # Using as a router
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # Not supported on 22.11
  # services.tailscale.useRoutingFeatures = "server";
}
