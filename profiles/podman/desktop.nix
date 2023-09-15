{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.podman-desktop
  ];

  virtualisation.podman = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "biweekly";
    };
  };
}
