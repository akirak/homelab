{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

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

  # Configuration for non-ZFS file systems on the system SSD
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/8d814cba-6716-4951-94b8-331025c318f2";
      preLVM = true;
    };
  };

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["defaults" "size=10G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/89D8-EFFA";
    fsType = "vfat";
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
