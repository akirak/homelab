{pkgs, ...}: {
  imports = [
    ../window-manager/generic.nix
    ./sway-utils.nix
  ];

  environment.systemPackages = [
    pkgs.xdg-utils
    pkgs.wlr-randr
  ];

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
    };
    xdgOpenUsePortal = true;
  };

  security.pam.services.swaylock = {};
}
