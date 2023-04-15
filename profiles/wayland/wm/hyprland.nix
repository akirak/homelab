{pkgs, ...}: {
  imports = [
    ../sessions.nix
  ];

  environment.systemPackages = [
    pkgs.wev
  ];

  programs.hyprland = {
    enable = true;
    package = pkgs.customPackages.hyprland;
    xwayland = {
      enable = true;
      hidpi = false;
    };
  };

  wayland.sessions = [
    {
      name = "Hyprland";
    }
  ];
}
