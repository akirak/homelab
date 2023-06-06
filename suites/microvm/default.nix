/*
Based on https://github.com/astro/microvm.nix/blob/main/flake.nix
*/
{
  hypervisor,
  config,
  lib,
  ...
}: {
  imports = [
    ../../profiles/microvm
  ];

  system.stateVersion = lib.mkDefault "23.05";

  services.getty.helpLine = ''
    From this console, you can log in as "root" with an empty password.
  '';

  users.users.root.password = "";

  microvm = {
    mem = 2048;
    vcpu = 2;
  };
}
