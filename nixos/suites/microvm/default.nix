/*
Based on https://github.com/astro/microvm.nix/blob/main/flake.nix
*/
{...}: {
  imports = [
    ../../profiles/microvm
  ];

  services.getty.helpLine = ''
    From this console, you can log in as "root" with an empty password.
  '';

  users.users.root.password = "";

  microvm = {
    mem = 2048;
    vcpu = 2;
  };
}
