{
  pkgs,
  homeUser,
  emacs-config,
  ...
}: {
  home.username = homeUser;
  home.homeDirectory = "/home/${homeUser}";
  home.stateVersion = "22.11";

  imports = [
    ../../hm/core.nix
  ];

  targets.crostini.enable = true;

  programs.emacs-twist = {
    enable = true;
    settings = {
      extraFeatures = [
      ];
    };
  };
}
