{
  imports = [
    ../profiles/openssh.nix
  ];

  networking.firewall.enable = true;
}
