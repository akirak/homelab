# This profile can be used for fresh NixOS installation from kexec.
# See https://github.com/numtide/nixos-remote
{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = ["nvme"];

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  boot.loader.grub = {
    device = "/dev/sda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
}
