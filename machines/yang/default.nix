{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  stateVersion = "23.11";

  metadata = lib.importTOML ../metadata.toml;

  ip = metadata.hosts.yang.ipAddress;
in
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    # Create a non-wheel user for hosting some personal data.
    ../../profiles/users/1000/on-server.nix
    ../../profiles/openssh
    ../../profiles/onedev
    ../../profiles/docker
    ../../profiles/acme/internal.nix
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

  environment.systemPackages = [
    # Tools for diagnostics
    pkgs.tcpdump
    pkgs.dig
  ];

  services.caddy = {
    enable = true;
    virtualHosts."test.nicesunny.day" = {
      useACMEHost = "nicesunny.day";
      extraConfig = ''
        respond "Hello from Caddy"
      '';
    };
    virtualHosts."test:80" = {
      extraConfig = ''
        redir https://test.nicesunny.day
      '';
    };
  };

  services.coredns = {
    enable = true;
    config = ''
      nicesunny.day {
        hosts {
          ${ip} test test.nicesunny.day
          ${ip} grafana grafana.nicesunny.day
          ${
            lib.pipe metadata.hosts [
              (lib.filterAttrs (_: attrs: attrs ? ipAddress))
              (lib.mapAttrsToList (name: attrs: "${attrs.ipAddress} ${name} ${name}.nicesunny.day"))
              (builtins.concatStringsSep "\n")
            ]
          }
          fallthrough
        }
        log
      }
    '';
  };

  services.resolved.enable = false;

  networking.firewall.allowedTCPPorts = [
    443
    80
    2019 # Allow installation of local certificates for caddy
    53 # DNS
  ];
  networking.firewall.allowedUDPPorts = [
    53 # DNS
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
