{pkgs, ...}: {
  imports = [
    ../base
    ../../profiles/nix
  ];

  environment.systemPackages = [
    pkgs.git
    # Provided from disko flake via overlayModule
    pkgs.disko

    # Import useful packages from the package list in
    # nixos/modules/profiles/base.nix of nixpkgs.
    pkgs.gptfdisk
    pkgs.efibootmgr
    pkgs.efivar
    pkgs.parted
    pkgs.gptfdisk
    pkgs.ddrescue
    pkgs.ccrypt
    pkgs.cryptsetup
    pkgs.mkpasswd

    pkgs.fuse
    pkgs.fuse3
    pkgs.rsync
    pkgs.socat

    pkgs.ntfsprogs
    pkgs.dosfstools
    pkgs.mtools
    pkgs.xfsprogs.bin
    pkgs.jfsutils
    pkgs.f2fs-tools

    pkgs.unzip
    pkgs.zip
  ];
}
