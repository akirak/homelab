{
  config,
  lib,
  ...
}: {
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  services.xrdp.defaultWindowManager =
    lib.mkIf config.services.xrdp.enable "startplasma-x11";
}
