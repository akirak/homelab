{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../profiles/pipewire
  ];

  environment.systemPackages = with pkgs; [
    # flameshot
    handlr
  ];

  fonts = {
    packages = with pkgs; [
      customFontPackages.jetbrains-mono-nerdfont
      merriweather
      lato
    ];

    fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono NF" ];

      sansSerif = [ "Lato" ];

      serif = [ "Merriweather" ];
    };
  };

  systemd.services.setxkbmap = {
    enable = true;
    after = [ "post-resume.target" ];
    description = "Run setxkbmap";

    script = "/run/current-system/sw/bin/setxkbmap -option ctrl:nocaps";
    environment = {
      DISPLAY = ":0";
    };
  };

  services.xserver.xkb.layout = lib.mkDefault "us";
}
