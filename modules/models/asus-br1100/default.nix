{nixos-hardware}: {
  config,
  pkgs,
  ...
}: {
  imports = [
    (nixos-hardware.outPath + "/common/pc/laptop")
    (nixos-hardware.outPath + "/common/gpu/intel.nix")
    ./r8168.nix
  ];

  # I don't know if this parameter is necessary.
  boot.kernelParams = ["nouveau.modeset=0"];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_0;
}
