{pkgs, ...}: {
  imports = [
    ../sessions.nix
  ];

  environment.systemPackages = [
    pkgs.wev
  ];

  wayland.sessions = [
    {
      name = "Hyprland";
    }
  ];
}
