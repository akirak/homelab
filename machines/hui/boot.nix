{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [
    pkgs.lshw
    pkgs.git
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  boot.initrd.kernelModules = [
    "usbcore"
    "nvme"
    "sdhci_pci"
    "mmc_block"
    "xhci_hcd"
    "usb-storage"
  ];

  boot.initrd.luks.reusePassphrases = true;

  boot.supportedFilesystems = ["btrfs"];
  boot.initrd.supportedFilesystems = ["btrfs"];

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/78af0865-093e-4529-bf6a-841ee6b492e9";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=/root"
        "discard=async"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8627-ED16";
      fsType = "vfat";
      neededForBoot = true;
      options = [
        "fmask=0137"
        "dmask=0027"
      ];
    };

    "/nix" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=/nix"
        "compress=lz4"
        "noatime"
        "discard=async"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/109d2b63-22f6-4188-8dc5-8346617d3df3";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "4096m";

  boot.runSize = "64m";
  boot.devSize = "256m";
  boot.devShmSize = "256m";
}
