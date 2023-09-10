/*
Options taken from pleroma.nix
at <nixos/modules/services/networking/pleroma.nix>
in https://github.com/NixOS/nixpkgs
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.livebook;

  openScript = pkgs.writers.writeBashBin "open-livebook" ''
    set -euo pipefail

    if [[ ! -v DISPLAY ]] && [[ ! -v WAYLAND_DISPLAY ]]
    then
      echo "This command can be run only in a graphical environment" >&2
      exit 1
    fi

    err() {
      ${pkgs.notify-desktop}/bin/notify-desktop --app-name=Livebook "$@"
      exit 1
    }

    if ! systemctl is-active livebook.service >/dev/null
    then
      err "livebook.service is not running"
    fi

    if [[ $(systemctl show livebook.service --property=MainPID) =~ MainPID=([[:digit:]]+) ]]
    then
      pid=''${BASH_REMATCH[1]}
    else
      err "Failed to parse the main PID of the service"
    fi

    out="$(journalctl --no-pager -t livebook -g "Application running at" | tail -1)"

    if [[ -z "$out" ]]
    then
      err "There is no available information on the process in the journal. Can you restart it and try again?"
    fi

    if [[ $out =~ livebook\[([[:digit:]]+)\] ]] \
       && [[ ''${BASH_REMATCH[1]} = $pid ]] \
       && [[ $out =~ http://[^[:space:]]+ ]]
    then
      url="''${BASH_REMATCH[0]}"
    else
      err "Failed to parse the output of journalctl"
    fi

    if ! ${pkgs.handlr}/bin/handlr open "$url"
    then
      err "Failed to open the URL $url"
    fi
  '';
in {
  options = {
    services.livebook = with lib; {
      enable = mkEnableOption (lib.mdDoc "Elixir Livebook");

      package = mkOption {
        type = types.package;
        default = pkgs.livebook;
        defaultText = literalExpression "pkgs.livebook";
        description = lib.mdDoc "Livebook package to use.";
      };

      user = mkOption {
        type = types.str;
        default = "livebook";
      };

      group = mkOption {
        type = types.str;
        default = "livebook";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/livebook/data";
        readOnly = true;
        description = "Directory to be used as LIVEBOOK_DATA_PATH.";
      };

      settings = {
        ipAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "LIVEBOOK_IP";
        };

        port = mkOption {
          type = types.port;
          default = 0;
          description = "LIVEBOOK_PORT";
        };

        homeDirectory = mkOption {
          type = types.str;
          default = "/var/lib/livebook";
          description = "LIVEBOOK_HOME";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        description = "Livebook user";
        group = cfg.group;
        isSystemUser = true;
        createHome = true;
        home = "/var/lib/livebook";
        homeMode = "750";
        # Provide a shell with dependencies to allow administration. For
        # example, you can enter a shell with `sudo su - livebook` and install
        # hex by running `mix local.hex`.
        useDefaultShell = true;
        packages = cfg.package.nativeBuildInputs ++ cfg.package.buildInputs;
      };
      groups.${cfg.group} = {
      };
    };

    environment.systemPackages = [
      openScript
      (pkgs.makeDesktopItem {
        name = "open-livebook";
        desktopName = "Open Livebook";
        exec = "open-livebook";
        tryExec = "${openScript}/bin/open-livebook";
      })
    ];

    systemd.services.livebook = {
      description = "Elixir Livebook";
      wantedBy = ["multi-user.target"];

      path = [
        # osmon fails if /bin is not in the PATH.
        # Based on information at
        # <https://github.com/petrkozorezov/mynixos/blob/cb77c06627d0add7751ca019f9e010c898715815/system/modules/livebook.nix#L142>
        ""
      ];

      environment = {
        LIVEBOOK_DATA_PATH = cfg.dataDir;
        LIVEBOOK_IP = cfg.settings.ipAddress;
        LIVEBOOK_PORT = builtins.toString cfg.settings.port;
        LIVEBOOK_HOME = cfg.settings.homeDirectory;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        Type = "exec";

        ExecStart = "${cfg.package}/bin/livebook server";

        # If you ran a public instance, it might be important to set these
        # options properly, but I am only running a local private instance, so I
        # don't find it worth the effort.
        PrivateTmp = true;
        # ProtectHome = true;
        # ProtectSystem = "full";
        # PrivateDevices = false;
        # NoNewPrivileges = true;
        # CapabilityBoundingSet = "~CAP_SYS_ADMIN";
      };
    };
  };
}
