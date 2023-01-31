{homeUser, ...}: {
  imports = [
    ./boot.nix
    ../../suites/base
    ../../suites/graphical
    ../../suites/desktop
    ../../profiles/nix
    ../../profiles/sudo
    ../../profiles/tailscale
  ];

  networking.hostName = "hui";
  system.stateVersion = "22.11";
  disko.devices = import ./disko.nix {};

  networking = {
    firewall.enable = true;
    useDHCP = false;
    networkmanager.enable = true;
  };

  # systemd.services.NetworkManager-wait-online.enable = true;

  services.journald.extraConfig = ''
    SystemMaxFiles=5
  '';

  services.auto-cpufreq.enable = true;

  users.users.${homeUser} = {
    uid = 1000;
    isNormalUser = true;
    hashedPassword = "$6$3LmgpFGu4WEeoTss$9NQpF4CEO8ivu0uJTlDYXdiB6ZPHBsLXDZr.6S59bBNxmNuhirmcOmHTwhccdgSwq7sJOz2JbOOzmOCivxdak0";

    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
      "systemd-journal"
      # "docker"
    ];
  };
}
