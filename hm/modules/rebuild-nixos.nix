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
        if emacs_config="$(readlink -e "${cfg.emacsConfigDirectory}")"
        then
          flags=(--override-input emacs-config "''${emacs_config}" \
                 --update-input emacs-config/flake-pins \
                 --update-input emacs-config/twist-overrides)
        else
          flags=(--update-input emacs-config \
                 --update-input emacs-config/flake-pins \
                 --update-input emacs-config/twist-overrides)
        fi

        hostname="$(uname -n)"

        cd "${cfg.directory}"
        if nixos-rebuild switch \
            --flake ".#$hostname" \
            --option accept-flake-config true \
            --no-write-lock-file \
            --print-build-logs \
            --use-remote-sudo \
            ''${flags[@]}; then
          ${notify} -t 5000 'Switched to the new NixOS config'
        else
          ${notify} -t 5000 'nixos-rebuild has failed'
          read
        fi
      '')
    ];
  };
}
