{ lib, config, ... }:
{
  # fileSystems."/backup" = {
  #   device = "/dev/mapper/backup_rpool5";
  #   fsType = "ext4";
  #   neededForBoot = true;
  # };

  fileSystems."/var/lib/postgresql" = {
    # This pool name was a mistake
    device = "rpool5/safe/postgresql";
    fsType = "zfs";
    neededForBoot = true;
  };

  # You always have to backup databases. Automatic snapshots of ZFS do not work
  # for database backups, so set up a dataset (with optional automatic
  # snapshots) for backups and run pgbackup periodically.
  fileSystems.${config.services.postgresqlBackup.location} = {
    device = "rpool5/safe/pgbackup";
    fsType = "zfs";
    neededForBoot = true;
  };

  # Enable the transparent compression of ZFS
  services.postgresqlBackup = lib.mkIf config.services.postgresqlBackup.enable {
    compression = "none";
  };

  fileSystems."/var/lib/private" = {
    device = "rpool5/local/ollama";
    fsType = "zfs";
    # The root directory of this file system needs to have 0700 permission.
  };

  fileSystems."/var/lib/containers" = {
    device = "rpool5/local/containers";
    fsType = "zfs";
  };

  fileSystems."/media/virtualbox" = {
    device = "rpool5/safe/virtualbox";
    fsType = "zfs";
  };
}
