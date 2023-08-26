/*
Single-node k3s configuration.

Based on https://nixos.wiki/wiki/K3s#Single_node_setup
*/
{pkgs, ...}: {
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [6443];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  ];
  environment.systemPackages = [pkgs.k3s];
}
