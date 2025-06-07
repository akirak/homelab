{
  lib,
  config,
  ...
}: let
  cfg = config.programs.direnv;
in {
  programs.direnv = lib.mkIf cfg.enable (
    {
      enableZshIntegration = config.programs.zsh.enable;
    }
    // (
      if (builtins.compareVersions config.home.stateVersion "22.11" > 0)
      then {
        enableNushellIntegration =
          config.programs.nushell.enable;
      }
      else {}
    )
  );
}
