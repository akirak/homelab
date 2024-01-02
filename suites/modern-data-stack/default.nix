let
  inherit (builtins) toString;
in let
  backend = "podman";

  kestraPort = 9900;

  containers = {
    kestra = {
      image = "kestra/kestra:latest-full";
      user = "root";
      ports = [
        "127.0.0.1:${toString kestraPort}:8080"
      ];
      cmd = [
        "server"
        "local"
      ];
    };
  };
in {
  virtualisation.oci-containers = {
    inherit backend containers;
  };
}
