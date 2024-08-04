{ pkgs, ... }:
{
  home.packages = [
    # networking
    pkgs.dig
    pkgs.nmap
    pkgs.tcpdump
    pkgs.nssTools
  ];
}
