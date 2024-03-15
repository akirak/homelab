{
  lib,
  config,
  ...
}: let
  cfg = config.programs.eza;
in {
  config = {
    programs.eza = lib.mkIf cfg.enable {
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
