{pkgs, ...}: {
  services.yubikey-agent.enable = true;

  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  services.pcscd = {
    enable = true;
  };
}
