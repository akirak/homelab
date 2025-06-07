{
  lib,
  config,
  ...
}: {
  imports = [
    ../installer
    ../../profiles/openssh
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://akirak.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "akirak.cachix.org-1:WJrEMdV1dYyALkOdp/kAECVZ6nAODY5URN05ITFHC+M="
    ];
  };

  networking = {
    useDHCP = false;
    wireless.enable = false;
    networkmanager.enable = true;
  };

  system.stateVersion = lib.mkDefault lib.trivial.release;

  users.users.nixos = {
    uid = 1000;
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };
}
