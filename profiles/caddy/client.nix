# Install caddy command to install/uninstall certificates into the root store
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.caddy
    pkgs.nssTools # certutils
  ];
}
