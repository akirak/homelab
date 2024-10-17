{
  luksKey ? "/etc/luks.key",
  ssdDevice ? "/dev/disk/by-id/nvme-eui.ace42e001a6218fa2ee4ac0000000001",
  mmcDevice ? "/dev/disk/by-id/mmc-G1J39E_0x0e78c1a5",
  ...
}:
{
  disko.devices = {
    disk = {
      ssd = {
        device = ssdDevice;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              start = "0";
              end = "500MiB";
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
              name = "luks";
              start = "500MiB";
              end = "-8G";
              content = {
                type = "luks";
                name = "cryptroot";
                keyFile = luksKey;
                extraOpenArgs = [ "--allow-discards" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "discard=async" ];
                    };
                    "/nix" = {
                      mountOptions = [
                        "compress=lz4"
                        "noatime"
                        "discard=async"
                      ];
                    };
                    # "/home" = {
                    #   mountOptions = ["discard=async"];
                    # };
                  };
                };
              };
            };

            encryptedSwap = {
              name = "swap";
              start = "-8G";
              end = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };

      mmc = {
        device = mmcDevice;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "luks";
              start = "0";
              end = "100%";
              content = {
                type = "luks";
                name = "cryptdata";
                keyFile = luksKey;
                extraOpenArgs = [ "--allow-discards" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/data" = {
                      mountpoint = "/data";
                      mountOptions = [ "discard=async" ];
                    };
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
