{
  config,
  lib,
  ...
}: let
  cfg = config.xdg.mimeApps.defaultBrowser;
  inherit (lib) types;
in {
  options = {
    xdg.mimeApps.defaultBrowser = lib.mkOption {
      type = types.nullOr types.str;
      description = lib.mdDoc ''
        Desktop file for the browser. It should support both `text/html` and
        `x-scheme-handler/https`.
      '';
      default = null;
    };
  };

  config = {
    xdg.mimeApps.defaultApplications = lib.mkIf (cfg != null) {
      "text/html" = cfg;
      "x-scheme-handler/http" = cfg;
      "x-scheme-handler/https" = cfg;
    };
  };
}
