# Provide a podman-based environment for using podman-compose with docker
# compatibility to run a bunch of examples in Docker-based tutorials.
#
# Based on https://carlosvaz.com/posts/rootless-podman-and-docker-compose-on-nixos/
{ pkgs, ... }:
{
  imports = [
    ./.
    ../containers/rootless.nix
  ];

  virtualisation.podman = {
    # Make docker command available.
    dockerCompat = true;
  };

  environment.systemPackages = [
    pkgs.podman-compose
  ];
}
