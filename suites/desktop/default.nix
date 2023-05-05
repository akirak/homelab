{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ../../profiles/yubikey
    ../../profiles/users/primary-group.nix
  ];

  environment.sessionVariables = {
    "TMPDIR" = "/tmp";
  };

  networking.usePredictableInterfaceNames = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Tokyo";

  services.earlyoom.enable = true;
  services.psd.enable = true;

  # Allow mounting FUSE filesystems as a user.
  # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';
}
