{
  pkgs,
  modulesPath,
  ...
}:
let
  stateVersion = "24.11";
in
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
    ../../suites/server
    ./fs
    ./boot.nix
  ];

  system.stateVersion = stateVersion;

  # Needed for the ZFS pool.
  # Use `cat /etc/machine-id | cut -c1-8`
  networking.hostId = "4cc22902";

  boot.runSize = "64m";
  boot.devSize = "256m";
  boot.devShmSize = "256m";

  services.auto-cpufreq.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  environment.systemPackages = [
    pkgs.lshw
    pkgs.usbutils
    pkgs.pkgs.git
    pkgs.git-annex
  ];

  time.timeZone = "Asia/Tokyo";

  # services.scrutiny = {
  #   enable = true;
  #   # Access only locally for now
  #   openFirewall = false;
  #   settings = {
  #     web.listen = {
  #       port = 9233;
  #       host = "127.0.0.1";
  #     };
  #   };
  # };
}
