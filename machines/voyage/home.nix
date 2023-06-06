{
  pkgs,
  homeUser,
  emacs-config,
  ...
}: {
  home.username = homeUser;
  home.homeDirectory = "/home/${homeUser}";
  home.stateVersion = "23.05";

  imports = [
    ../../hm/core.nix
  ];

  targets.crostini.enable = true;

  services.cachix-agent = {
    enable = true;
    name = "voyage";
  };

  programs.rebuild-home.name = "voyage";

  programs.emacs-twist = {
    enable = true;
    settings = {
      extraFeatures = [
      ];
    };
  };
}
