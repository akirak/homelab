{pkgs, ...}: {
  services.yubikey-agent.enable = true;

  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  services.pcscd = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.yubikey-manager
    pkgs.yubikey-manager-qt
    pkgs.age-plugin-yubikey
  ];
}
