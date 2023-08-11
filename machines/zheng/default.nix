{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/headless.nix")
    ../../suites/server
    ../../profiles/tailscale
    ../../profiles/nginx
    ../../profiles/nix/cachix-deploy.nix
    ./boot.nix
  ];

  time.timeZone = "Asia/Tokyo";

  disko.devices = import ./disko.nix {};

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';

  boot.tmp.cleanOnBoot = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  zramSwap.enable = true;

  users.users.akirakomamura = {
    uid = 1000;
    isNormalUser = true;
  };
}
