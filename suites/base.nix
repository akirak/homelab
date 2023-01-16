{
  imports = [
    ../profiles/openssh.nix
  ];

  networking.firewall.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc.automatic = true;
  };
}
