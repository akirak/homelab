{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  # This kernel module is needed if and only if unlock LUKS devices on boot
  # boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # ZFS support
  boot.supportedFilesystems = ["zfs"];
  boot.initrd.supportedFilesystems = ["zfs"];
  boot.zfs.requestEncryptionCredentials = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
  # Configure ARC up to 4 GiB
  boot.kernelParams = ["zfs.zfs_arc_max=4294967296"];

  environment.systemPackages = [
    pkgs.lshw
    pkgs.git
  ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["defaults" "size=10G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B327-FDEA";
    fsType = "vfat";
    options = ["fmask=0137" "dmask=0027"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/f3125e1d-ef1a-4a93-82ee-29b74464b2c0";
    fsType = "f2fs";
  };

  swapDevices = [];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      # vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # hardware.bluetooth = {
  #   enable = true;
  # };

  boot.runSize = "64m";
  boot.devSize = "256m";
  boot.devShmSize = "256m";
}
