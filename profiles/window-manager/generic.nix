{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.networkmanagerapplet
    pkgs.elementary-xfce-icon-theme
  ];

  services.xserver = {
    xkb.options = "ctrl:nocaps";
    enableCtrlAltBackspace = true;
    # startDbusSession = true;
  };
  services.libinput = {
    enable = true;
    mouse = {
      disableWhileTyping = true;
    };
  };

  services.dbus = {
    enable = true;
    # socketActivated = true;
    packages = [pkgs.dconf];
  };

  # services.gnome.gnome-keyring.enable = true;

  services.blueman.enable = true;

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
}
