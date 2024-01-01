{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.timoni;
  inherit (lib) mkIf mkOption mkEnableOption types;
in {
  options = {
    programs.timoni = {
      enable = mkEnableOption (lib.mdDoc "Install timoni for development.");

      enableZshIntegration = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Zsh integration.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.timoni
    ];

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      source <(${pkgs.timoni}/bin/timoni completion zsh)
      compdef _timoni timoni
    '';
  };
}
