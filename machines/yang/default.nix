{
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  stateVersion = "23.11";
in
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    # Create a non-wheel user for hosting some personal data.
    ../../profiles/users/1000/on-server.nix
    ../../profiles/openssh
    ../../profiles/onedev
    ../../profiles/docker
    ./fs
    ./boot.nix
    ../../profiles/syncthing
  ];

  system.stateVersion = stateVersion;

  # Needed for the ZFS pool.
  # Use `cat /etc/machine-id | cut -c1-8`
  networking.hostId = "8425e349";

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # This option is enabled by default in nixos/modules/profiles/hardened.nix,
  # but needed to be turned off to load br_netfilter module for Docker.
  security.lockKernelModules = false;

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

  virtualisation.docker = {
    storageDriver = "zfs";
  };

  users.users.akirakomamura = {
    # Provide minimal packages needed for specific needs.
    packages = [
      pkgs.git
      pkgs.git-annex
    ];
  };

  time.timeZone = "Asia/Tokyo";
}
