let
  systemSsd = "/dev/disk/by-id/ata-CT500BX500SSD1_2432E8BE667B";
  cryptBtrfs = "root";
in
{
  imports = [
    (import ./btrfs.nix {
      device = "/dev/mapper/${cryptBtrfs}";
    })
  ];

  boot.initrd.luks.devices.${cryptBtrfs} = {
    device = "${systemSsd}-part2";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=1G"
        "mode=755"
      ];
    };

    "/boot" = {
      device = "${systemSsd}-part1";
      fsType = "vfat";
      options = [
        "fmask=0137"
        "dmask=0027"
      ];
    };
  };

  services.smartd = {
    enable = true;
    devices = [
      { device = systemSsd; }
    ];
  };
}
