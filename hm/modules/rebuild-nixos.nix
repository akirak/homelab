{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;

  cfg = config.programs.nixos-rebuild-and-notify;

  notify = "${pkgs.notify-desktop}/bin/notify-desktop -r nixos-rebuild";
in {
  options = {
    programs.nixos-rebuild-and-notify = {
      enable = lib.mkEnableOption (lib.mdDoc "Install nixos-rebuild-and-notify script");

      directory = lib.mkOption {
        type = types.str;
        description = "Directory containing the NixOS configuration";
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
      (pkgs.writeShellScriptBin "nixos-rebuild-and-notify" ''
        emacs_config="${cfg.emacsConfigDirectory}"
        if [[ -d "''${emacs_config}" ]]
        then
          flags=(--override-input emacs-config $(readlink -f "''${emacs_config}") \
                 --override-input emacs-config/flake-pins github:akirak/flake-pins)
        else
          flags=()
        fi

        cd "${cfg.directory}"
        if cachix watch-exec akirak nixos-rebuild -- switch \
            --flake `readlink -f "${cfg.directory}"`#`uname -n` \
            --option accept-flake-config true \
            --print-build-logs \
            --use-remote-sudo \
            --no-write-lock-file \
            ''${flags[@]}; then
          ${notify} -t 5000 'nixos-rebuild successfully finished'
        else
          ${notify} -t 5000 'nixos-rebuild has failed'
          read
        fi
      '')
    ];
  };
}
