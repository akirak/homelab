{
  config,
  modulesPath,
  ...
}: let
  stateVersion = "23.11";
in {
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    ../../profiles/openssh
    ./fs
    ./boot.nix
  ];

  system.stateVersion = stateVersion;

  # Needed for the ZFS pool.
  # Use `cat /etc/machine-id | cut -c1-8`
  networking.hostId = "8425e349";

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.runSize = "64m";
  boot.devSize = "256m";
  boot.devShmSize = "256m";

  services.auto-cpufreq.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  services.nginx = {
    enable = true;
    virtualHosts.localhost.locations."/" = {
      index = "index.html";
      root = "/var/www";
    };
  };

  networking.firewall.allowedTCPPorts = [
    # nginx
    80
  ];

  networking = {
    useNetworkd = true;
  };

  systemd.network = {
    networks = {
      "20-lan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
        };
      };
    };
  };
}
