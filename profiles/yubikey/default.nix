{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.yubikey-manager
    pkgs.yubikey-personalization
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  services.pcscd = {
    enable = true;
  };
}
