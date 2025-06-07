{pkgs, ...}: {
  boot.kernelModules = ["iwlwifi"];
  hardware.firmware = [pkgs.wireless-regdb];
  hardware.enableRedistributableFirmware = true;
}
