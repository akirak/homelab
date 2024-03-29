# This profile can be used for NixOS installation with nixos-infect.
{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
}
