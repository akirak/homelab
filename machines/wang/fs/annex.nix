{
  boot.initrd.luks.reusePassphrases = true;

  boot.initrd.luks.devices = {
    annex1 = {
      device = "/dev/disk/by-partuuid/31efb973-e795-4dcf-b72b-19cc7faefb14";
    };
    annex2 = {
      device = "/dev/disk/by-partuuid/a3e493bc-346d-4df0-9491-3d6bb986a0ed";
    };
  };

  fileSystems = {
    "/git-annex/wang-annex1" = {
      device = "/dev/mapper/annex1";
      fsType = "ext4";
      options = [
        "noatime"
      ];
    };
    "/git-annex/wang-annex2" = {
      device = "/dev/mapper/annex2";
      fsType = "ext4";
      options = [
        "noatime"
      ];
    };
  };
}
