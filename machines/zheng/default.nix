{
  pkgs,
  lib,
  ...
}: let
  stateVersion = "23.11";
in {
  imports = [
    # (modulesPath + "/profiles/headless.nix")
    # ../../profiles/nix/cachix-deploy.nix
    ../../profiles/openssh
    ./router.nix
  ];

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];

  # Replace the raspberry-pi-4 nixos-hardware module with an explicit list of
  # kernel modules. See
  # https://www.eisfunke.com/posts/2023/nixos-on-raspberry-pi-4.html
  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"
    "vc4"
    "pcie_brcmstb"
    "reset-raspberrypi"
  ];

  # Force no ZFS
  boot.supportedFilesystems =
    lib.mkForce
    [
      "btrfs"
      # "reiserfs"
      "vfat"
      "f2fs"
      # "xfs"
      "ntfs"
      # "cifs"
    ];

  hardware.deviceTree = {
    kernelPackage = pkgs.linux_rpi4;
  };

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = stateVersion;

  time.timeZone = "Asia/Tokyo";

  nix.settings.allowed-users = ["root"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=10day
  '';

  boot.tmp.cleanOnBoot = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  zramSwap.enable = true;

  sdImage.compressImage = false;
}
