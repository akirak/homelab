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
    emacsclient.enable = true;
    directory = ".local/share/emacs";
    earlyInitFile = emacs-config.outPath + "/emacs/early-init.el";
    createInitFile = true;
    config = emacs-config.packages.${pkgs.system}.emacs-config.override {
      extraFeatures = [
      ];
      prependToInitFile = ''
        ;; -*- lexical-binding: t; no-byte-compile: t; -*-
        (setq custom-file (locate-user-emacs-file "custom.el"))
        (setq akirak/enabled-status-tags t)
      '';
    };
  };
}
