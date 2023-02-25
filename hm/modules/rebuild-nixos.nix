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
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "nixos-rebuild-and-notify" ''
        cd $HOME/config
        if nixos-rebuild switch --flake `readlink -f "${cfg.directory}"`#`uname -n` \
            --print-build-logs --use-remote-sudo; then
          ${notify} -t 5000 'nixos-rebuild successfully finished'
        else
          ${notify} -t 5000 'nixos-rebuild has failed'
          read
        fi
      '')
    ];
  };
}
