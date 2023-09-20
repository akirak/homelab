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
                 --update-input emacs-config/flake-pins)
        else
          flags=()
        fi

        cd "${cfg.directory}"
        if out=$(nix build "`readlink -f ${cfg.directory}`.#nixosConfigurations.`uname -n`.config.system.build.toplevel" \
            --accept-flake-config --no-write-lock-file --print-out-paths \
            ''${flags[@]}) && sudo $out/bin/switch-to-configuration; then
          ${notify} -t 5000 'nixos-rebuild successfully finished'

          echo "Uploading to cachix..."
          cachix push akirak $out
        else
          ${notify} -t 5000 'nixos-rebuild has failed'
          read
        fi
      '')
    ];
  };
}
