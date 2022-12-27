{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];

  zramSwap.enable = true;
  boot.cleanTmpDir = true;

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
}
