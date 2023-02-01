{pkgs, ...}: {
  imports = [
    ../sessions.nix
  ];

  environment.systemPackages = [
    (pkgs.callPackage ./makeWrapper.nix {
      sessionName = "firefox-session";
      command = "firefox";
    })
  ];

  wayland.sessions = [
    {
      name = "firefox-session";
    }
  ];
}
