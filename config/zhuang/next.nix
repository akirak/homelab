{ pkgs, ...}:
{
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
