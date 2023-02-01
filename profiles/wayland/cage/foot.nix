{pkgs, ...}: {
  imports = [
    ../sessions.nix
  ];

  environment.systemPackages = [
    (pkgs.callPackage ./makeWrapper.nix {
      sessionName = "foot-session";
      command = "foot";
    })
  ];

  wayland.sessions = [
    {
      name = "foot-session";
    }
  ];
}
