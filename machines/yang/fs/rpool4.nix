{
  boot.zfs = {
    requestEncryptionCredentials = [
      "rpool4"
    ];
  };
  services.zfs = {
    autoSnapshot.enable = true;
    autoScrub.enable = true;
  };

  boot.kernelParams = [
    # 3 GiB
    "zfs.zfs_arc_max=3221225472"
  ];

  fileSystems =
    builtins.mapAttrs (_mountPoint: device: {
      inherit device;
      fsType = "zfs";
    }) {
      "/var/log" = "rpool4/log";
    };
}
