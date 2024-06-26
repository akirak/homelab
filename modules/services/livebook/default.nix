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
  cfg = config.services.my-livebook;

  openScript = pkgs.writers.writeBashBin "open-livebook" ''
    set -euo pipefail

    LIVEBOOK_SERVICE="''${LIVEBOOK_SERVICE:-livebook.service}"

    if [[ ! -v DISPLAY ]] && [[ ! -v WAYLAND_DISPLAY ]]
    then
      echo "This command can be run only in a graphical environment" >&2
      exit 1
    fi

    err() {
      echo "$@" >&2
      ${pkgs.notify-desktop}/bin/notify-desktop --app-name=Livebook "$@"
      exit 1
    }

    if ! systemctl is-active "''${LIVEBOOK_SERVICE}" >/dev/null
    then
      err "''${LIVEBOOK_SERVICE} is not running"
    fi

    if [[ $(systemctl show "''${LIVEBOOK_SERVICE}" --property=MainPID) =~ MainPID=([[:digit:]]+) ]]
    then
      pid=''${BASH_REMATCH[1]}
    else
      err "Failed to parse the main PID of the service"
    fi

    out="$(journalctl --no-pager -t livebook -g "Application running at" | tail -1)"

    if [[ -z "$out" ]]
    then
      ${pkgs.notify-desktop}/bin/notify-desktop 'Restarting livebook service to retrieve the PID'
      systemctl restart --wait "''${LIVEBOOK_SERVICE}"
      LIVEBOOK_SERVICE="''${LIVEBOOK_SERVICE}" exec "$0"
    fi

    if [[ $out =~ livebook\[([[:digit:]]+)\] ]] \
       && [[ ''${BASH_REMATCH[1]} = $pid ]] \
       && [[ $out =~ http://[^[:space:]]+ ]]
    then
      url="''${BASH_REMATCH[0]}"
    else
      err "Failed to parse the output of journalctl"
    fi

    echo "Opening $url"

    if ! ${pkgs.handlr}/bin/handlr open "$url"
    then
      err "Failed to open the URL $url"
    fi
  '';
in {
  options = {
    services.my-livebook = with lib; {
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

        enableNix = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Nix package manager for the user.";
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = lib.mdDoc "List of packages that are made available to the user.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    ids = {
      # Check nixos/modules/misc/ids.nix in nixpkgs to ensure there is no
      # collision
      #
      # If the user/group has been already created with a different numeric ID,
      # first disable the livebook service to remove the user and group and
      # then re-enable it to recreate them.
      uids.livebook = 293;
      gids.livebook = 293;
    };

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
        uid = config.ids.uids.livebook;
      };
      groups.${cfg.group} = {
        gid = config.ids.gids.livebook;
      };
    };

    nix.settings.allowed-users = lib.optionals cfg.settings.enableNix [
      cfg.user
    ];

    environment.systemPackages = [
      openScript
      (pkgs.makeDesktopItem {
        name = "open-livebook";
        desktopName = "Open Livebook";
        exec = "open-livebook";
        tryExec = "${openScript}/bin/open-livebook";
      })
    ];

    # Without epmd already running, livebook tries to start it on its own, which
    # can conflict with another instance of epmd required by other services,
    # e.g. rabbitmq.
    services.epmd.enable = true;

    systemd.services.livebook = {
      description = "Elixir Livebook";
      wantedBy = ["multi-user.target"];
      requires = [
        "epmd.socket"
      ];
      after = [
        "epmd.socket"
      ];

      path =
        [
          # osmon fails if /bin is not in the PATH.
          # Based on information at
          # <https://github.com/petrkozorezov/mynixos/blob/cb77c06627d0add7751ca019f9e010c898715815/system/modules/livebook.nix#L142>
          ""
        ]
        # This is not a proper way to add Nix packages to the environment, but I
        # was unable to find other way. Adding packages to
        # users.users.livebook.packages didn't work :(
        ++ cfg.settings.extraPackages
        ++ (lib.optionals cfg.settings.enableNix [
          config.nix.package
          "${cfg.settings.homeDirectory}/.nix-profile"
        ]);

      environment = {
        LIVEBOOK_DATA_PATH = cfg.dataDir;
        LIVEBOOK_IP = cfg.settings.ipAddress;
        LIVEBOOK_PORT = builtins.toString cfg.settings.port;
        LIVEBOOK_HOME = cfg.settings.homeDirectory;
        RELEASE_COOKIE = "${cfg.settings.homeDirectory}/.cookie";
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        Type = "exec";

        StandardOutput = "journal";
        StandardError = "journal";

        ExecStart = "${cfg.package}/bin/livebook start";

        # Create a release cookie. The code is based on
        # https://github.com/nixos/nixpkgs/blob/nil/nixos/modules/services/networking/pleroma.nix
        ExecStartPre = "${pkgs.writers.writeBashBin "write-cookie" ''
          RELEASE_COOKIE="${cfg.settings.homeDirectory}/.cookie"

          if [[ ! -f "''${RELEASE_COOKIE}" ]]
          then
            dd if=/dev/urandom bs=1 count=16 | ${pkgs.hexdump}/bin/hexdump -e '16/1 "%02x"' > "''${RELEASE_COOKIE}"
          fi
        ''}/bin/write-cookie";

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
