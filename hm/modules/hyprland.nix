{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland or { enable = false; };

  footEnabled = config.programs.foot.enable;

  systemdTarget = "hyprland-session.target";

  systemdStartAfterThis = {
    Unit = {
      After = [ systemdTarget ];
    };
    Install = {
      WantedBy = [ systemdTarget ];
    };
  };

  runInTerminal = pkgs.writeShellScript "run-in-term" ''
    windowclass=$(basename "$1")

    options=()
    case "$windowclass" in
      hyprprop)
        options+=(--hold)
        ;;
    esac

    footclient -a "$windowclass" ''${options[@]} "$@"
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fuzzel
      dunst
      channels.hyprland-contrib.shellevents
      channels.hyprland-contrib.hyprprop
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = systemdTarget;
    };

    xdg.configFile."waybar/config".source = pkgs.callPackage ../lib/waybar-config.nix {
      modulesCenter = [ "hyprland/window" ];
      modulesRight = ms: ms ++ [ "hyprland/submap" ];
    };

    programs.foot.server.enable = lib.mkIf footEnabled true;
    systemd.user.services.foot = lib.mkIf footEnabled systemdStartAfterThis;

    systemd.user.services.dunst = lib.mkIf config.services.dunst.enable systemdStartAfterThis;

    services.kanshi = {
      enable = true;
      systemdTarget = lib.mkForce systemdTarget;
    };

    wayland.windowManager.hyprland = {
      systemd.enable = true;
      xwayland.enable = true;

      settings = {
        "$mod" = "SUPER";

        input = {
          kb_layout = "us";
          kb_options = "ctrl:nocaps";
        };

        general = {
          border_size = 5;
          # TODO: Use a proper color scheme
          "col.active_border" = "rgba(ffaaff88)";
          "col.inactive_border" = "rgba(00000088)";
          gaps_in = 2;
          gaps_out = 5;
        };

        bindm = [
          "$mod        ,mouse:272,movewindow"
          "$mod        ,mouse:273,resizewindow"
        ];

        bind = [
          # Hyprland admin
          "$mod SHIFT , Q, exec, pkill Hyprland"

          # Launcher
          "$mod SHIFT , Return, exec, footclient"
          "$mod       , Space, exec, fuzzel -T ${runInTerminal}"
          "$mod       , E, exec, emacsclient -c -a emacs"
          "$mod SHIFT , S, exec, flameshot gui"
          "$mod       , F9, exec, foot --title \"Rebuilding NixOS...\" nixos-rebuild-and-notify"

          # Window management
          "$mod       , C , killactive"
          "$mod       , T, togglefloating"
          "$mod       , F, fullscreen"
          "$mod       , ', pin"

          # Monitor
          "$mod       , bracketleft, focusmonitor, -1"
          "$mod       , bracketright, focusmonitor, 1"
          "$mod SHIFT , bracketleft, movewindow, mon:-1"
          "$mod SHIFT , bracketright, movewindow, mon:1"
          "$mod       , Backspace, swapactiveworkspaces, current +1"

          # Master layout
          "$mod       , Return, layoutmsg, swapwithmaster auto"
          "$mod       , M, layoutmsg, focusmaster auto"
          "$mod       , minus, splitratio, -0.15"
          "$mod       , equal, splitratio, 0.15"

          # Move focus
          "$mod       , h, movefocus, l"
          "$mod       , j, movefocus, d"
          "$mod       , k, movefocus, u"
          "$mod       , l, movefocus, r"
          "$mod SHIFT , h, swapwindow, l"
          "$mod SHIFT , j, swapwindow, d"
          "$mod SHIFT , k, swapwindow, u"
          "$mod SHIFT , l, swapwindow, r"
          "$mod       , period, focusurgentorlast"
          "$mod       , comma, togglespecialworkspace"
          "$mod       , s, movetoworkspace, special"

          # Workspace management
          "$mod       , f5, exec,   hyprctl keyword general:layout dwindle"
          "$mod       , f6, exec,   hyprctl keyword general:layout master"

          "$mod       , 1, workspace, 1"
          "$mod SHIFT , 1, movetoworkspace, 1"
          "$mod       , 2, workspace, 2"
          "$mod SHIFT , 2, movetoworkspace, 2"
          "$mod       , 3, workspace, 3"
          "$mod SHIFT , 3, movetoworkspace, 3"
          "$mod       , 4, workspace, 4"
          "$mod SHIFT , 4, movetoworkspace, 4"
          "$mod       , 5, workspace, 5"
          "$mod SHIFT , 5, movetoworkspace, 5"
        ];

        windowrulev2 =
          let
            defaultDialogSize = "780 600";

            exactClass = className: "class:^(${className})$";

            exactTitle = className: "title:^(${className})$";

            andRules = builtins.concatStringsSep ",";

            generateRules =
              rules: windows:
              lib.flatten (builtins.map (window: (builtins.map (rule: "${rule},${window}") rules)) windows);
          in
          [ "workspace special,class:^(foot)$,title:^(Rebuilding)" ]
          ++ (generateRules [
            "float"
            "size 80% 80%"
            "center"
          ] [ (exactClass "btop") ])
          ++ (generateRules
            [
              "float"
              "size ${defaultDialogSize}"
              "center"
            ]
            [
              (andRules [
                (exactClass "chromium")
                (exactTitle "Open Files")
              ])
              (exactTitle "Volume Control") # pavucontrol
              (exactClass "com.rafaelmardojai.Blanket")
              (exactTitle "Android Studio Setup Wizard")
            ]
          )
          ++ (generateRules
            [
              "float"
              "center"
            ]
            [
              (exactClass "mpv")
              (exactClass "VirtualBox Manager")
            ]
          );
      };
    };
  };
}
