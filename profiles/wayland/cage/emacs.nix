{pkgs, ...}: {
  imports = [
    ../sessions.nix
  ];

  environment.systemPackages = [
    (pkgs.callPackage ./makeWrapper.nix {
      sessionName = "emacs-session";
      command = "emacs";
    })
  ];

  wayland.sessions = [
    {
      name = "emacs-session";
    }
  ];
}
