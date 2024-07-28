{
  services.vaultwarden = {
    enable = true;
    # Ensure this directory is persisted
    backupDir = "/var/backup/vaultwarden";

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
