# Based on https://github.com/weissi1994/nix/blob/938a0098120128bf9b5e89a7e62ebbae371bb993/hosts/_mixins/server/roles/immich.nix
let
  inherit (builtins) toString map attrNames;
in
  {
    lib,
    pkgs,
    ...
  }: let
    backend = "podman";

    podName = "datastack";

    kestraPort = 9900;

    mkContainer = name: attrs:
      lib.nameValuePair "${podName}-${name}"
      (attrs
        // {
          autoStart = true;
          extraOptions =
            [
              "--pod"
              podName
            ]
            ++ (attrs.extraOptions or []);
        });

    containers = lib.mapAttrs' mkContainer {
      kestra = {
        image = "kestra/kestra:latest-full";
        # Needed iff the container is not run as root
        # user = "root";
        ports = [
          "${toString kestraPort}:8080"
        ];
        cmd = [
          "server"
          "local"
        ];
      };
    };

    containerUnits = map (
      name: "${backend}-${name}.service"
    ) (attrNames containers);

    createPodService = "create-${podName}-pod";
  in {
    systemd.services.${createPodService} = {
      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
      # Don't share the net namespace and explicitly specify published ports.
      script = ''
        ${pkgs.podman}/bin/podman pod create --replace \
           --share ipc,uts --publish ${toString kestraPort} \
           --name ${podName}
      '';
      wantedBy = containerUnits;
      before = containerUnits;
    };

    virtualisation.oci-containers = {
      inherit backend containers;
    };
  }
