# This configuration is insecure and hence should be used for development on a
# host that is not public-facing.
{ config, ... }:
let
  inherit (builtins) toString;

  cfg = config.virtualisation.oci-containers.containers.sequin;

  database = "sequin";

  # port = 7376;

  redisPort = 7378;

  configFile = ./contrib/playground.yml;

  redisData = "/var/lib/sequin-redis";
in
{
  virtualisation.oci-containers.containers = {
    sequin = {
      image = "sequin/sequin:latest";
      autoStart = true;
      environment = {
        PG_HOSTNAME = "localhost";
        PG_DATABASE = database;
        PG_PORT = toString config.services.postgresql.settings.port;
        PG_USERNAME = "postgres";
        PG_PASSWORD = "postgres";
        PG_POOL_SIZE = "20";
        CONFIG_FILE_PATH = "/config/playground.yml";
        REDIS_URL = "redis://localhost:${toString redisPort}";
        # Only for development
        SECRET_KEY_BASE = "wDPLYus0pvD6qJhKJICO4dauYPXfO/Yl782Zjtpew5qRBDp7CZvbWtQmY0eB13If";
        VAULT_KEY = "2Sig69bIpuSm2kv0VQfDekET2qy8qUZGI8v3/h3ASiY=";
      };
      # ports = [
      #   "127.0.0.1:${toString port}:7376"
      # ];
      volumes = [
        "${configFile}:/config/playground.yml"
      ];
      networks = [
        "host"
      ];
      dependsOn = [
        "sequin-redis"
        # PostgreSQL is run as a normal NixOS service, so it is added as a
        # systemd dependency.
      ];
    };

    sequin-redis = {
      image = "redis:7";
      autoStart = true;
      cmd = [
        "--port"
        "6379"
      ];
      ports = [
        "${toString redisPort}:6379"
        # "127.0.0.1:${toString redisPort}:6379"
      ];
      volumes = [
        "${redisData}:/data"
      ];
    };
  };

  systemd.services.${cfg.serviceName} = {
    after = [
      "postgresql.service"
      "redis.service"
    ];
    reloadIfChanged = true;
  };

  systemd.services.${config.virtualisation.oci-containers.containers.sequin-redis.serviceName} = {
    preStart = "mkdir -p ${redisData}";
  };

  services.postgresql = {
    ensureDatabases = [
      database
    ];
  };
}
