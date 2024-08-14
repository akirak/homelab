{ lib, config, ... }:
{
  # A ZFS volume for disposable container images.
  fileSystems."/images" = {
    # This pool name was a mistake
    device = "rpool3/encrypt/local/images";
    fsType = "zfs";
    neededForBoot = true;
  };

  # fileSystems."/backup" = {
  #   device = "/dev/mapper/backup_rpool3";
  #   fsType = "ext4";
  #   neededForBoot = true;
  # };

  fileSystems."/var/lib/postgresql" = {
    # This pool name was a mistake
    device = "rpool3/encrypt/safe/postgresql";
    fsType = "zfs";
    neededForBoot = true;
  };

  # You always have to backup databases. Automatic snapshots of ZFS do not work
  # for database backups, so set up a dataset (with optional automatic
  # snapshots) for backups and run pgbackup periodically.
  fileSystems.${config.services.postgresqlBackup.location} = {
    device = "rpool3/encrypt/safe/pgbackup";
    fsType = "zfs";
    neededForBoot = true;
  };

  # Enable the transparent compression of ZFS
  services.postgresqlBackup = lib.mkIf config.services.postgresqlBackup.enable {
    compression = "none";
  };

  # You will require github:nix-community/impermanence to use this
  environment.persistence."/images" = {
    directories = [
      # On this machine, I use Docker only for development, so the files are
      # disposable.
      "/var/lib/docker"
    ];
  };
}
