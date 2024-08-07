{
  imports = [ ./extras.nix ];

  fileSystems."/persist" = {
    device = "rpool3/encrypt/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "rpool3/encrypt/safe/home";
    fsType = "zfs";
  };

  # You will require github:nix-community/impermanence to use this
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/tmp"
      "/var/lib/bluetooth"
      "/var/lib/livebook"
      "/var/lib/rabbitmq"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bitwarden_rs"
      "/var/backup/vaultwarden"
    ];
  };
}
