{...}: {
  imports = [
    ../sessions.nix
  ];

  wayland.sessions = [
    {
      name = "labwc";
    }
  ];
}
