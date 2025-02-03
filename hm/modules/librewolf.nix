{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.librewolf;
in
{
  # Basically just stolen from https://nixos.wiki/wiki/Librewolf
  programs.librewolf = lib.mkIf cfg.enable {
    # Enable WebGL, cookies and history
    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
    };
  };
}
