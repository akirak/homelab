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
    pkgs.yubioath-flutter
    pkgs.age-plugin-yubikey
  ];
}
