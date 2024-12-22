{
  pkgs,
  config,
  ...
}:
{
  # At present, wired interface does not work even with this kernel module due
  # to a common "ucsi_acpi usbc000:00: ppm init failed" error. This issue may be
  # fixed at some point, but I am not sure.
  boot.extraModulePackages = [
    (config.boot.kernelPackages.r8168.overrideAttrs (
      import ../../overrides/r8168.nix { inherit pkgs; }
    ))
  ];
  boot.blacklistedKernelModules = [ "r8169" ];
}
