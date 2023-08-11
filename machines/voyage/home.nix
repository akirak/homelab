{homeUser, ...}: {
  home.username = homeUser;
  home.homeDirectory = "/home/${homeUser}";

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
