{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.yubikey-manager
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  services.pcscd = {
    enable = true;
  };
}
