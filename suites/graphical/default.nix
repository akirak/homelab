{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # flameshot
    pavucontrol
    handlr
  ];

  fonts = {
    packages = with pkgs; [
      my-overlay.jetbrains-mono-nerdfont
      merriweather
      lato
    ];

    fontconfig.defaultFonts = {
      monospace = ["JetBrains Mono NF"];

      sansSerif = ["Lato"];

      serif = ["Merriweather"];
    };
  };

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  systemd.services.setxkbmap = {
    enable = true;
    after = ["post-resume.target"];
    description = "Run setxkbmap";

    script = "/run/current-system/sw/bin/setxkbmap -option ctrl:nocaps";
    environment = {
      DISPLAY = ":0";
    };
  };

  services.xserver.xkb.layout = lib.mkDefault "us";
}
