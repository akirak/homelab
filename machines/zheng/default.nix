{
  pkgs,
  lib,
  ...
}: let
  stateVersion = "23.11";
in {
  imports = [
    # (modulesPath + "/profiles/headless.nix")
    # ../../suites/server
    # ../../profiles/tailscale
    # ../../profiles/nginx
    # ../../profiles/nix/cachix-deploy.nix
    # ./boot.nix
    # (import ./disko.nix {})
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
    #  filter = "bcm2711-rpi-4-b.dtb";
    kernelPackage = pkgs.linux_rpi4;
  };

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = stateVersion;

  time.timeZone = "Asia/Tokyo";

  # nix.settings.allowed-users = ["root"];

  # services.journald.extraConfig = ''
  #   SystemMaxUse=1G
  #   MaxFileSec=10day
  # '';

  # boot.tmp.cleanOnBoot = true;

  powerManagement.cpuFreqGovernor = "schedutil";

  # zramSwap.enable = true;

  users.users.akirakomamura = {
    uid = 1000;
    isNormalUser = true;
    hashedPassword = "$y$j9T$6LW46s8StpmW2y3zzZ.qk0$ze1ABRCpZAPJ6Vp8LpTje8k5sH81P2HyyARByG598DB";

    extraGroups = [
      "wheel"
    ];
  };

  sdImage.compressImage = false;
}
