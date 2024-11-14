{
  config,
  lib,
  pkgs,
  ...
}:
let
  enableFoot = config.programs.foot.enable;
  enableWayland = true;

  defaultBrowser = if config.programs.firefox.enable then "firefox.desktop" else null;

  defaultApplications = {
    "image/svg+xml" = [
      defaultBrowser
    ];
  };
in
{
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

      # API development
      # hoppscotch

      # database admin
      beekeeper-studio

      # fonts
      channels.fonts.jetbrains-mono-nerdfont
      # Japanese
      ipafont
    ])
    ++ lib.optionals enableWayland [
      pkgs.wayshot
      pkgs.wf-recorder
      pkgs.slurp # Used with wayshot

      (pkgs.writeShellApplication {
        name = "lock-screen";
        runtimeInputs = [ pkgs.swaylock-effects ];
        # TODO: Use a color scheme
        text = ''
          swaylock -f --clock --fade-in 0.5
        '';
      })
    ];

  xdg.mime.enable = true;
  xdg.mimeApps = lib.mkIf (defaultBrowser != null) {
    enable = true;
    inherit defaultBrowser;
    inherit defaultApplications;
    associations.added = defaultApplications;
  };

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
