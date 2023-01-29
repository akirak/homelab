{
  config,
  lib,
  ...
}: let
  sshPort = 22;
in {
  microvm.forwardPorts = [
    {
      host.port = 2222;
      guest.port = sshPort;
    }
  ];

  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    ports = [sshPort];
    openFirewall = true;
    permitRootLogin = "yes";
  };
}
