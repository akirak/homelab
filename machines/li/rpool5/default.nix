{
  imports = [ ./extras.nix ];

  fileSystems."/persist" = {
    device = "rpool5/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "rpool5/safe/home";
    fsType = "zfs";
  };

  # You will require github:nix-community/impermanence to use this
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/tmp"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/livebook"
      "/var/lib/rabbitmq"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bitwarden_rs"
      "/var/backup/vaultwarden"

      # /var/lib/private is required by ollama, and it will contain
      # /var/lib/private/scrutiny.
      #
      # Also note that /var/lib/private/ollama should be a separate file system,
      # as it will contain LLM models.
      {
        directory = "/var/lib/private";
        user = "root";
        group = "root";
        mode = "700";
      }
    ];
  };
}
