{pkgs, ...}: {
  imports = [
    ./.
  ];

  environment.systemPackages = [
    pkgs.kind
    pkgs.kubectl
  ];
}
