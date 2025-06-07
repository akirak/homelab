{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isDarwin;
  inherit (config.home) homeDirectory;
in {
  xdg.configHome = mkIf (!isDarwin) "${homeDirectory}/.config";
  xdg.cacheHome = mkIf (!isDarwin) "${homeDirectory}/.cache";
  xdg.dataHome = mkIf (!isDarwin) "${homeDirectory}/.local/share";
}
