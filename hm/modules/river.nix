{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.river;
in {
  options = {
    programs.river = {
      enable = lib.mkEnableOption (lib.mdDoc "River composite manager for Wayland");
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # riverctl and rivertile need to be in PATH
      river

      (pkgs.writeShellScriptBin "river-session" ''
        export XKB_DEFAULT_LAYOUT=us
        export XKB_DEFAULT_OPTIONS=ctrl:nocaps
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        export MOZ_ENABLE_WAYLAND=1
        # Set SWAYSOCK to use swaymsg and other sway-compatible utilities
        export SWAYSOCK=''${XDG_RUNTIME_DIR}/wayland-1
        exec ${pkgs.dbus}/bin/dbus-run-session -- river
      '')

      wofi
    ];

    xdg.configFile."river/init".source = ../etc/river/init;

    # It might be better to define services.river option so that these services
    # are not triggered by the program.
    services.dunst.enable = true;
    services.kanshi.enable = true;

    programs.waybar = {
      enable = true;

      settings = {
        mainBar = {
          layer = "top";
          height = 30;
          spacing = 4;

          "modules-left" = [
            # "river/tags"
          ];

          "modules-center" = [
            # "river/mode"
            "river/window"
          ];

          "modules-right" = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            # "backlight"
            "keyboard-state"
            # "sway/language"
            "battery"
            "battery#bat2"
            "clock"
            "tray"
          ];

          "keyboard-state" = {
            numlock = true;
            capslock = true;
            format = "{name} {icon}";
            "format-icons" = {
              locked = "";
              unlocked = "";
            };
          };

          pulseaudio = {
            format = "{format_source} {volume}% {icon}";
          };

          clock = {
            format = "{:%Y-%m-%d (%a) W%W %H:%M}";
          };
        };
      };
    };
  };
}
