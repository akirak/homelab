{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.cachix
  ];

  # To start an agent, you have to create /etc/cachix-agent.token file which
  # contains an CACHIX_AGENT_TOKEN environment entry. The file is not created in
  # nixos-rebuild.
  services.cachix-agent.enable = true;
}
