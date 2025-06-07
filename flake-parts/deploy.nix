{ inputs, ... }:
let
  inherit (inputs) self stable;
in
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      deployToHost =
        hostName:
        pkgs.writeShellApplication {
          name = "deploy";
          runtimeInputs = [ stable.legacyPackages.${system}.nixos-rebuild ];
          meta.description = "A nixos-rebuild wrapper that targets a host on LAN";
          text = ''
            target_host="${hostName}"

            usage() {
              echo "deploy [--target-host IP] switch|test ARGS"
            }

            while [[ $# -gt 0 ]]; do
              case "$1" in
                --help|-h)
                  usage
                  exit
                  ;;
                --target-host)
                  target_host="$2"
                  shift; shift
                  ;;
                *)
                  mode="$1"
                  shift
                  break
                  ;;
              esac
            done

            if ! [[ -v mode ]]; then
              echo >&2 "You need to specify one of the subcommands of nixos-rebuild"
              exit 1
            fi

            set -x

            # Don't look up known_hosts file because the host key is updated on every deploy
            NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
              nixos-rebuild "$mode" \
              --flake ".#${hostName}" \
              --target-host "root@''${target_host}" \
              --option accept-flake-config true \
              "$@"
          '';
        };
    in
    {
      packages = lib.mapAttrs' (
        hostName: _: lib.nameValuePair "deploy-${hostName}" (deployToHost hostName)
      ) self.nixosConfigurations;
    };
}
