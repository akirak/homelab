{ pkgs, ...}:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # ssh
      22
      # tailscale
      41641
    ];
  };

  services.tailscale = {
    enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Akira Komamura";
      user.email = "akira.komamura@gmail.com";
    };
  };

  environment.systemPackages = [
    pkgs.git-annex
  ];
}
