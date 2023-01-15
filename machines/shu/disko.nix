# Based on https://github.com/numtide/nixos-remote-examples/blob/9768e438b1467ec55d42e096860e7199bd1ef43d/disk-config.nix
{ disks ? ["/dev/sda"], ... }: {
  disk.sda = {
    device = builtins.elemAt disks 0;
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "boot";
          type = "partition";
          start = "0";
          end = "1M";
          part-type = "primary";
          flags = ["bios_grub"];
        }
        {
          type = "partition";
          name = "ESP";
          start = "1MiB";
          end = "100MiB";
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
          name = "root";
          type = "partition";
          start = "100MiB";
          end = "100%";
          part-type = "primary";
          bootable = true;
          content = {
            type = "lvm_pv";
            vg = "pool";
          };
        }
      ];
    };
  };
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        root = {
          type = "lvm_lv";
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [
              "defaults"
            ];
          };
        };
      };
    };
  };
}
