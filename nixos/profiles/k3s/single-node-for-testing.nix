{pkgs, ...}: {
  imports = [
    ./single-node.nix
  ];

  services.k3s = {
    # https://0to1.nl/post/k3s-kubectl-permission/
    environmentFile = pkgs.writeText "environment" ''
      K3S_KUBECONFIG_MODE="644"
    '';
  };
}
