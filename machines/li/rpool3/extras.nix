{ lib, config, ... }:
{
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

  fileSystems."/media/virtualbox" = {
    device = "rpool3/encrypt/safe/virtualbox";
    fsType = "zfs";
  };
}
