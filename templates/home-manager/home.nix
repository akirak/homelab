{
  pkgs,
  homeUser,
  emacs-config,
  ...
}: {
  home.username = homeUser;
  home.homeDirectory = "/home/${homeUser}";

  programs.emacs-twist = {
    enable = true;
    settings = {
      extraFeatures = [
      ];
    };
  };
}
