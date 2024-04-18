{
  config,
  lib,
  pkgs,
  ...
}: let
  enableFoot = config.programs.foot.enable;
  enableWayland = true;
in {
  programs = {
    # alacritty.enable = enableGraphical;
    mpv.enable = true;
    firefox.enable = true;
    foot.enable = enableWayland;
    foot.server.enable = enableFoot;
    # TODO: Add font package
    foot.settings.main.font = "JetBrainsMono NF:size=10.5";
  };

  home.packages =
    (with pkgs; [
      blanket
      pavucontrol

      # fonts
      my-overlay.jetbrains-mono-nerdfont
      # Japanese
      ipafont
    ])
    ++ lib.optionals enableWayland [
      pkgs.wayshot
      pkgs.wf-recorder
      pkgs.slurp # Used with wayshot

      (pkgs.writeShellApplication {
        name = "lock-screen";
        runtimeInputs = [pkgs.swaylock-effects];
        # TODO: Use a color scheme
        text = ''
          swaylock -f --clock --fade-in 0.5
        '';
      })
    ];

  xdg.mimeApps.defaultBrowser =
    lib.mkIf config.programs.firefox.enable
    "firefox.desktop";

  systemd.user.services.emacs = {
    Service = {
      Environment = lib.optionals enableWayland [
        "MOZ_ENABLE_WAYLAND=1"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    };
  };

  systemd.user.services.foot = lib.mkIf config.programs.foot.server.enable {
    Service = {
      Environment = lib.mkForce [
        "WAYLAND_DISPLAY=wayland-1"
        "PATH=${
          lib.concatMapStrings (dir: dir + ":") config.home.sessionPath
        }${config.home.profileDirectory}/bin"
      ];
    };
  };
}
