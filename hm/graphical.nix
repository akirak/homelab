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
      jetbrains-mono-nerdfont
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
}
