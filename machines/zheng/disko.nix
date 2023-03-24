# Based on https://github.com/numtide/nixos-remote-examples/blob/9768e438b1467ec55d42e096860e7199bd1ef43d/disk-config.nix
{
  disks ? [
    "/dev/disk/by-id/usb-Corsair_Voyager_GTX_511190321261A0D60061-0:0"
  ],
  luksKey ? "/etc/luks-cryptroot.key",
  ...
}: {
  disk.mmcblk0 = {
    device = builtins.elemAt disks 0;
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          type = "partition";
          name = "ESP";
          start = "0";
          end = "500MiB";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "defaults"
            ];
          };
        }

        {
          type = "partition";
          name = "luks";
          start = "500MiB";
          end = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            keyFile = luksKey;
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = ["discard=async"];
                };
                "/nix" = {
                  mountOptions = ["compress=zstd" "noatime" "discard=async"];
                };
                "/home" = {
                  mountOptions = ["compress=zstd" "discard=async"];
                };
              };
            };
          };
        }
      ];
    };
  };
}
