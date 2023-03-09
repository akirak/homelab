{
  homeUser,
  pkgs,
  emacs-config,
  ...
}: let
  mainMonitor = {
    criteria = "Unknown VA32AQ K3LMAS000141 (HDMI-A-2)";
    mode = "2560x1440";
    position = "0,0";
  };

  subMonitor = {
    criteria = "Dell Inc. DELL S2421HS CBPT223 (DP-1)";
    mode = "1920x1080";
    position = "2560,100";
  };
in {
  imports = [
    ./boot.nix
    ./rpool2
    ../../suites/base
    ../../suites/graphical
    ../../suites/desktop
    ../../profiles/home-manager
    ../../profiles/nix
    ../../profiles/sudo
    ../../profiles/tailscale
    ../../profiles/wayland/wm/river.nix
    ../../profiles/nix/cachix-deploy.nix
    ../../profiles/postgresql/development.nix
  ];

  # Needed for the ZFS pool.
  networking.hostId = "8425e349";

  system.stateVersion = "22.11";
  # I didn't use disko when I first set up this machine.
  # disko.devices = import ./disko.nix {};

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
  };
  # systemd.services.NetworkManager-wait-online.enable = true;

  environment.systemPackages = [
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

  home-manager.users.${homeUser} = {
    programs.chromium = {
      enable = true;
      extensions = [
        {
          # Google Input Tools
          id = "mclkkofklkfljcocdinagocijmpgbhab";
        }
      ];
    };

    home.packages = [
      pkgs.wine
      pkgs.tenacity
    ];

    services.kanshi.profiles = {
      docked.outputs = [mainMonitor subMonitor];
      undocked.outputs = [mainMonitor];
    };

    programs.river.enable = true;

    programs.gpg.enable = true;

    programs.emacs-twist = {
      enable = true;
      emacsclient.enable = true;
      directory = ".local/share/emacs";
      earlyInitFile = emacs-config.outPath + "/emacs/early-init.el";
      createInitFile = true;
      config = emacs-config.packages.${pkgs.system}.emacs-config.override {
        extraFeatures = [
          # "beancount"
          "mermaid"
          # "ChatGPT"
          "copilot"
          "OCaml"
          "Coq"
          # "Lean4"
          # "lsp_mode"
        ];
        prependToInitFile = ''
          ;; -*- lexical-binding: t; no-byte-compile: t; -*-
          (setq custom-file (locate-user-emacs-file "custom.el"))
          (setq akirak/enabled-status-tags t)
        '';
      };
    };
  };
}