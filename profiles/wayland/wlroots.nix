{pkgs, ...}: {
  imports = [
    ../window-manager/generic.nix
    ./sway-utils.nix
  ];

  environment.systemPackages = [
    pkgs.xdg-utils
    pkgs.wlr-randr
  ];

  xdg.portal.wlr = {
    enable = true;
  };

  security.pam.services.swaylock = {};
}
