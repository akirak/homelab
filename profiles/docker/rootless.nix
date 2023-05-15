{
  imports = [
    ./default.nix
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
