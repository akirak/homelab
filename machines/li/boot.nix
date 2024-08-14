{
  config,
  pkgs,
  lib,
  ...
}:
let
  annex-dm = "local_annex";
in
{
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  # This kernel module is needed if and only if unlock LUKS devices on boot
  # boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
  # Configure ARC up to 4 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=4294967296" ];

  environment.systemPackages = [
    pkgs.lshw
    pkgs.git
  ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=10G"
      "mode=755"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B327-FDEA";
    fsType = "vfat";
    options = [
      "fmask=0137"
      "dmask=0027"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/89ca01cd-558b-410a-b282-3af5601b9f97";
    fsType = "ext4";
  };

  boot.initrd.luks.devices.${annex-dm} = {
    device = "/dev/disk/by-uuid/2f67dfa5-200f-4d38-b96d-2aabbd9f5186";
    allowDiscards = true;
  };

  fileSystems."/git-annex/${config.networking.hostName}" = {
    device = "/dev/mapper/${annex-dm}";
    fsType = "ext4";
    options = [
      "relatime"
      "discard"
    ];
  };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
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

  services.smartd = {
    enable = true;
    devices = [
      { device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2316E6CCB0BC"; }
      { device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2316E6CCB574"; }
    ];
  };

  services.scrutiny = {
    enable = true;
    # Access only locally for now
    openFirewall = false;
    settings = {
      web.listen = {
        port = 9233;
        host = "127.0.0.1";
      };
    };
  };
}
