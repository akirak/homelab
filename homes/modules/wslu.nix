{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.wslu;
in {
  options = {
    programs.wslu = {
      enable = lib.mkEnableOption "Enable WSL utilities.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.wslu
      (pkgs.makeDesktopItem {
        name = "wslview";
        desktopName = "wslview";
        exec = "wslview";
      })
    ];

    xdg.mimeApps.defaultBrowser = lib.mkDefault "wslview.desktop";
  };
}
