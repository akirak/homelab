{
  virtualisation.oci-containers = {
    # Not sure if it works with podman. There is no specific recommendation for
    # OneDev itself, but I will follow the documentation for now.
    backend = "docker";

    # docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/onedev:/opt/onedev -p 6610:6610 -p 6611:6611 1dev/server
    containers.onedev = {
      image = "1dev/server";
      ports = [
        "6610:6610"
        "6611:6611"
      ];
      volumes = [
        "/var/lib/onedev:/opt/onedev"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
