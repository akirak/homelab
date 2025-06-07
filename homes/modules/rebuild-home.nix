{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;

  cfg = config.programs.rebuild-home;

  notify = "${pkgs.notify-desktop}/bin/notify-desktop -r home-manager";
in {
  options = {
    programs.rebuild-home = {
      enable = lib.mkOption {
        type = types.bool;
        description = "Install rebuild-home script";
        default = config.targets.genericLinux.enable || pkgs.stdenv.isDarwin;
      };

      name = lib.mkOption {
        type = types.str;
        description = "Name of the home-manager configuration";
      };

      configDirectory = lib.mkOption {
        type = types.str;
        description = "Directory containing the home-manager configuration";
        default = "$HOME/config";
      };

      emacsConfigDirectory = lib.mkOption {
        type = types.str;
        description = "Directory containing the Emacs configuration";
        default = "$HOME/emacs-config";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "rebuild-home" ''
        emacs_config="${cfg.emacsConfigDirectory}"
        if [[ -d "''${emacs_config}" ]]
        then
          flags=(--override-input emacs-config $(readlink -f "''${emacs_config}")
                 --override-input emacs-config/flake-pins github:akirak/flake-pins)
        else
          flags=()
        fi

        cd "${cfg.configDirectory}"
        if ${pkgs.nix-output-monitor}/bin/nom build "#homeConfigurations.${cfg.name}" \
            --option accept-flake-config true \
            --print-build-logs \
            ''${flags[@]} \
            && result/activate; then
          ${notify} -t 5000 'Successfully switched to a new home-manager generation'
        else
          ${notify} -t 5000 'Failed to switch to a new home-manager generation'
          read
        fi
      '')
    ];
  };
}
