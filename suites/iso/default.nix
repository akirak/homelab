{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    ../base
    (modulesPath + "/installer/cd-dvd/channel.nix")
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
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

  # Faster compression algorithm. See https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  system.stateVersion = lib.mkDefault lib.trivial.release;

  environment.systemPackages = [
    pkgs.git
    # Provided from disko flake via overlayModule
    pkgs.disko
  ];
}
