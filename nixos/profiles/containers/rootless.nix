{
  imports = [
    ./.
  ];

  virtualisation.containers = {
    # Based on https://carlosvaz.com/posts/rootless-podman-and-docker-compose-on-nixos/
    storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
        # The size can be large, so don't store the directory on tmpfs.
        # Instead, you can create a separate file system.
        # rootless_storage_path = "/tmp/containers-$USER";
        options.overlay.mountopt = "nodev,metacopy=on";
      };
    };
  };
}
