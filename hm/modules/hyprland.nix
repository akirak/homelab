{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.wayland.windowManager.hyprland or {enable = false;};

  waybarConfig = pkgs.callPackage ../lib/waybar-config.nix {
    modulesCenter = [
      "hyprland/window"
    ];
    modulesRight = ms: ms ++ [
      "hyprland/submap"
    ];
  };

  instanceEnv = "HYPRLAND_INSTANCE_SIGNATURE";

  # If there is an Emacs daemon running across NixOS configuration switches or
  # Hyprland restarts, Emacs can have a different value of
  # HYPRLAND_INSTANCE_SIGNATURE environment variable from the actually running
  # one, which can cause hyprctl to fail. It is better to synchronize the value.
  notifyToEmacs = pkgs.writeShellScript "notify-hyprland-instance" ''
    if [[ -S "''${XDG_RUNTIME_DIR}/emacs/server" ]] \
     && command -v emacsclient >/dev/null \
     && [[ -v ${instanceEnv} ]]
    then
      echo "Updating ${instanceEnv} environment variable inside Emacs"
      emacsclient --eval "(setenv "${instanceEnv}" "''${${instanceEnv}}")"
    fi
  '';
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fuzzel
      dunst
      channels.hyprland-contrib.shellevents
      channels.hyprland-contrib.hyprprop
    ];

    programs.waybar = {
      enable = true;
    };

    xdg.configFile."waybar/config".source = waybarConfig;

    xdg.configFile."hypr/hyprland.conf".text = ''

      $mod = SUPER

      input {
          kb_layout = us
          kb_options=ctrl:nocaps
      }

      general {
        gaps_in = 5
        gaps_out = 5
        border_size = 2
        # TODO: Use a proper color scheme
        col.active_border = rgb(ff0000) rgb(000000) 60deg;
        col.inactive_border = rgb(cccccc) rgb(000000) 60deg;
      }

      exec-once = dunst &
      exec-once = waybar &
      exec-once = foot --server

      exec = ${notifyToEmacs}

      # Mouse
      bindm=$mod        ,mouse:272,movewindow
      bindm=$mod        ,mouse:273,resizewindow

      # Hyprland admin
      bind = $mod SHIFT , Q, exec, pkill Hyprland

      # Launcher
      bind = $mod SHIFT , Return, exec, footclient
      bind = $mod       , Space, exec, fuzzel
      bind = $mod       , E, exec, emacsclient -c -a emacs
      bind = $mod SHIFT , S, exec, flameshot gui
      bind = $mod       , F9, exec, footclient --title "Rebuilding NixOS..." nixos-rebuild-and-notify

      # Window management
      bind = $mod       , C , killactive
      bind = $mod       , T, togglefloating
      bind = $mod       , F, fullscreen
      bind = $mod       , ', pin

      # Monitor
      bind = $mod       , bracketleft, focusmonitor, -1
      bind = $mod       , bracketright, focusmonitor, 1
      bind = $mod SHIFT , bracketleft, movewindow, mon:-1
      bind = $mod SHIFT , bracketright, movewindow, mon:1
      bind = $mod       , Backspace, swapactiveworkspaces, current +1

      # Master layout
      bind = $mod       , Return, layoutmsg, swapwithmaster auto
      bind = $mod       , M, layoutmsg, focusmaster auto
      bind = $mod       , minus, splitratio, -0.15
      bind = $mod       , equal, splitratio, 0.15

      # Move focus
      bind = $mod       , h, movefocus, l
      bind = $mod       , j, movefocus, d
      bind = $mod       , k, movefocus, u
      bind = $mod       , l, movefocus, r
      bind = $mod SHIFT , h, swapwindow, l
      bind = $mod SHIFT , j, swapwindow, d
      bind = $mod SHIFT , k, swapwindow, u
      bind = $mod SHIFT , l, swapwindow, r
      bind = $mod       , period, focusurgentorlast
      bind = $mod       , comma, togglespecialworkspace

      # Workspace management
      bind = $mod       , f5, exec,   hyprctl keyword general:layout dwindle
      bind = $mod       , f6, exec,   hyprctl keyword general:layout master

      bind = $mod       , 1, workspace, 1
      bind = $mod SHIFT , 1, movetoworkspace, 1
      bind = $mod       , 2, workspace, 2
      bind = $mod SHIFT , 2, movetoworkspace, 2
      bind = $mod       , 3, workspace, 3
      bind = $mod SHIFT , 3, movetoworkspace, 3
      bind = $mod       , 4, workspace, 4
      bind = $mod SHIFT , 4, movetoworkspace, 4
      bind = $mod       , 5, workspace, 5
      bind = $mod SHIFT , 5, movetoworkspace, 5

      windowrulev2 = workspace special,class:^(foot)$,title:^(Rebuilding)
      # Dialog
      windowrulev2 = float,class:^(chromium)$,title:^(Open Files)$
      windowrulev2 = size 780 600,class:^(chromium)$,title:^(Open Files)$
      windowrulev2 = center,class:^(chromium)$,title:^(Open Files)$

      # Volume control (pavucontrol)
      windowrulev2 = float,class:^(pavucontrol)$
      windowrulev2 = size 780 600,class:^(pavucontrol)$
      windowrulev2 = center,class:^(pavucontrol)$
    '';
  };
}
