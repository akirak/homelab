# Use a non-ZFS encrypted partition for a Nix store, downloads, git-annex
# repositories, and other temporary files.
{
  device,
  hostName,
}: {
  fileSystems =
    builtins.mapAttrs (_mountpoint: {
      subvol,
      mountOptions,
      neededForBoot ? false,
    }: {
      inherit device neededForBoot;
      fsType = "btrfs";
      options =
        [
          "subvol=${subvol}"
          "compress=zstd"
        ]
        ++ mountOptions;
    }) {
      "/nix" = {
        subvol = "nix";
        mountOptions = ["noatime"];
        neededForBoot = true;
      };
      # Working space for applications
      "/home" = {
        subvol = "home";
        mountOptions = ["relatime"];
      };
      # Storage for disposable files, e.g. downloads
      "/cache" = {
        subvol = "cache";
        mountOptions = ["noatime"];
        neededForBoot = true;
      };
      # Other persistent files (e.g. /var/tmp) and static data that should not
      # be put in the world-wide Nix store
      "/persist" = {
        subvol = "persist";
        mountOptions = ["noatime"];
        neededForBoot = true;
      };
      "/git-annex/${hostName}" = {
        subvol = "git-annex";
        mountOptions = ["noatime"];
      };
    };

  environment.persistence."/cache" = {
    directories = [
      "/var/cache"
      "/var/db/dhcpcd"
    ];
  };

  environment.persistence."/persist" = {
    directories = [ "/var/tmp" ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
