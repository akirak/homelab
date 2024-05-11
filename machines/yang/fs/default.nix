{config, ...}: let
  sataSsd = "/dev/disk/by-id/ata-Samsung_SSD_860_QVO_1TB_S59HNG0N413450P";
  cryptBtrfs = "crypted";
in {
  imports = [
    (import ./btrfs.nix {
      device = "/dev/mapper/${cryptBtrfs}";
      hostName = config.networking.hostName;
    })
    ./rpool4.nix
  ];

  boot.initrd.luks.devices.${cryptBtrfs} = {
    device = "${sataSsd}-part3";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=1G" "mode=755"];
    };

    "/boot" = {
      device = "${sataSsd}-part1";
      fsType = "vfat";
      options = ["fmask=0137" "dmask=0027"];
    };
  };
}
