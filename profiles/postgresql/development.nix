{ lib, pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;

      settings = {
        # Default: 5432
        port = 5432;

        # Enable logical replication for certain use cases.
        # See https://kinsta.com/blog/postgresql-replication/ and
        # https://electric-sql.com/docs/usage/installation/postgres
        wal_level = "logical";
      };

      # Specify an explicit major version
      # package = pkgs.postgresql_14;

      # Trust local access
      authentication = pkgs.lib.mkOverride 12 ''
        local all all trust
        host all all localhost trust
      '';

      ensureUsers = [ { name = "postgres"; } ];

      enableTCPIP = false;

      # Set the data directory explicitly
      # dataDir = "/var/lib/postgresql/14";
    };

    pgadmin = {
      # Currently fails to build
      # enable = true;
      # Default
      port = 5050;
      initialEmail = "akira.komamura@gmail.com";
      initialPasswordFile = "/persist/etc/pgpasswd";
    };

    postgresqlBackup = {
      enable = true;
      # PostgreSQL dump and ZFS snapshot must not occur simultaneously.
      startAt = "*-*-* *:05,20,35,50:00";
      location = "/var/backup/postgresql";
      backupAll = lib.mkDefault true;
    };
  };
}
