# Based on https://github.com/numtide/nixos-remote-examples/blob/9768e438b1467ec55d42e096860e7199bd1ef43d/disk-config.nix
{
  disks ? [ "/dev/sda" ],
  luksKey ? "/persist/luks-cryptroot.key",
  ...
}:
{
  disko.devices = {
    disk.sda = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            start = "0";
            end = "1M";
            type = "EF02";
          };

          ESP = {
            start = "1MiB";
            end = "100MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };

          luks = {
            start = "100MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              keyFile = luksKey;
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        # mode = "mirror";
        rootFsOptions = {
          "com.sun:auto-snapshot" = "false";
        };

        mountpoint = "/";

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}
