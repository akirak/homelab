{ homeUser, pkgs, ... }:
let
  mainMonitor = {
    criteria = "Unknown VA32AQ K3LMAS000141 (HDMI-A-2)";
    mode = "2560x1440";
    position = "1920,0";
  };

  subMonitor = {
    criteria = "Dell Inc. DELL S2421HS CBPT223 (DP-1)";
    mode = "1920x1080";
    position = "0,380";
  };
in
{
  imports = [
    ./boot.nix
    ./rpool5
    ../../suites/base
    ../../suites/graphical
    ../../suites/desktop
    ../../profiles/locale
    ../../profiles/home-manager
    ../../profiles/nix
    ../../profiles/sudo
    ../../profiles/tailscale
    ../../profiles/vaultwarden
    # ../../profiles/rabbitmq/development.nix
    ../../profiles/networking/usb-tether1.nix
    ../../profiles/wayland/wm/hyprland.nix
    ../../profiles/wayland/cage/foot.nix
    # ../../profiles/wayland/wm/river.nix
    # ../../profiles/nix/cachix-deploy.nix
    ../../profiles/postgresql/development.nix
    ../../profiles/virtualbox-host
    ../../profiles/dpt-rp1
    # ../../profiles/docker/rootless.nix
    # ../../profiles/docker
    # ../../profiles/docker/kind.nix
    # ../../profiles/k3s/single-node-for-testing.nix
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.intel-compute-runtime
      pkgs.intel-media-driver
    ];
  };

  system.stateVersion = "23.05";

  # Needed for the ZFS pool.
  networking.hostId = "8425e349";

  # I didn't use disko when I first set up this machine.
  # disko.devices = import ./disko.nix {};

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
  };
  # systemd.services.NetworkManager-wait-online.enable = true;

  environment.systemPackages = [
    pkgs.clinfo
    pkgs.hunspellDicts.en_US
    pkgs.hunspellDicts.en_GB-ise
  ];

  services.journald.extraConfig = ''
    SystemMaxFiles=5
  '';

  services.auto-cpufreq.enable = true;

  zramSwap = {
    enable = true;
  };

  users.users.${homeUser} = {
    description = "Akira Komamura";
    uid = 1000;
    isNormalUser = true;
    hashedPassword = "$6$3LmgpFGu4WEeoTss$9NQpF4CEO8ivu0uJTlDYXdiB6ZPHBsLXDZr.6S59bBNxmNuhirmcOmHTwhccdgSwq7sJOz2JbOOzmOCivxdak0";

    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
      "systemd-journal"
      "docker"
      "livebook"
    ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      # You have to install *.desktop files to the directory
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t -s /etc/wayland-sessions";
      user = homeUser;
    };
  };

  services.my-livebook = {
    enable = true;
    settings = {
      ipAddress = "127.0.0.1";
      port = 8200;
      enableNix = true;
    };
  };

  services.ollama = {
    enable = true;
    acceleration = false;
    # /var/lib/private is on a separate file system
  };

  services.postgresql = {
    package = pkgs.postgresql_14;
    extraPlugins = with pkgs.postgresql14Packages; [
      pgmq
    ];
  };

  home-manager.users.${homeUser} = {
    imports = [
      ../../hm/basic.nix
      ../../hm/extra.nix
      ../../hm/graphical.nix
    ];

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        {
          # Google Input Tools
          id = "mclkkofklkfljcocdinagocijmpgbhab";
        }
      ];
    };

    home.stateVersion = "23.05";

    home.packages = [
      pkgs.rclone
      # pkgs.wine
      # pkgs.tenacity
      # pkgs.microsoft-edge
      # pkgs.zoom-us
    ];

    services.kanshi.settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          mainMonitor
          subMonitor
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [ mainMonitor ];
      }
      {
        profile.name = "as_secondary";
        profile.outputs = [ subMonitor ];
      }
    ];

    wayland.windowManager.hyprland.enable = true;

    # programs.river.enable = true;

    programs.gpg.enable = true;

    programs.emacs-twist = {
      enable = true;
      settings = {
        extraFeatures = [
          "beancount"
          # "ChatGPT"
          "OCaml"
          "Emacs"
          "Emacs__lisp"
          "Org"
          # "Coq"
          # "Lean4"
          # "lsp_mode"
        ];
      };
    };
  };
}
