{
  imports = [
    ./.
  ];

  # See https://nixos.wiki/wiki/Podman
  virtualisation.podman = {
    dockerCompat = true;
    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };
}
