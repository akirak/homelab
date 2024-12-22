{
  boot.zfs = {
    requestEncryptionCredentials = [
      "storage1"
    ];
  };

  services.zfs = {
    autoSnapshot.enable = true;
    autoScrub.enable = true;
  };

  boot.kernelParams = [
    # 20 GiB
    "zfs.zfs_arc_max=21474836480"
  ];
}
