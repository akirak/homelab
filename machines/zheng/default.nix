{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/headless.nix")
    ../../suites/base
    ../../profiles/tailscale
    ../../profiles/nginx
    ../../profiles/nix/cachix-deploy.nix
    ./boot.nix
  ];

  system.stateVersion = "22.11";
  time.timeZone = "Asia/Tokyo";

  disko.devices = import ./disko.nix {};

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';

  boot.cleanTmpDir = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  zramSwap.enable = true;

  users.users.akirakomamura = {
    uid = 1000;
    isNormalUser = true;
  };
}
