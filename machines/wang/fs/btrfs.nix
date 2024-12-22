# Use a non-ZFS encrypted partition for a Nix store, downloads, git-annex
# repositories, and other temporary files.
{
  device,
}:
{
  fileSystems =
    builtins.mapAttrs
      (
        _mountpoint:
        {
          subvol,
          mountOptions ? [ ],
          neededForBoot ? false,
        }:
        {
          inherit device neededForBoot;
          fsType = "btrfs";
          options = [
            "subvol=${subvol}"
            "compress=zstd"
          ] ++ mountOptions;
        }
      )
      {
        "/nix" = {
          subvol = "nix";
          mountOptions = [ "noatime" ];
          neededForBoot = true;
        };
        "/var/log" = {
          subvol = "var/log";
          neededForBoot = true;
        };
        # Other persistent files (e.g. /var/tmp) and static data that should not
        # be put in the world-wide Nix store
        "/persist" = {
          subvol = "persist";
          neededForBoot = true;
        };
      };

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
