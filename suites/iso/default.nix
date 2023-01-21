{lib, pkgs, config, modulesPath, ...}:
{
  imports = [
    ../base
    (modulesPath + "/installer/cd-dvd/channel.nix")
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # Faster compression algorithm. See https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  system.stateVersion = lib.mkDefault lib.trivial.release;

  environment.systemPackages = [
    pkgs.git
    # Provided from disko flake via overlayModule
    pkgs.disko
  ];
}
