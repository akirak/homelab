{
  # You will require github:nix-community/impermanence to use this
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/livebook"
      "/etc/NetworkManager/system-connections"
    ];
  };
}
