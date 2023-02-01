{
  homeUser,
  pkgs,
  emacs-config,
  ...
}: {
  imports = [
    ./boot.nix
    ../../suites/base
    ../../suites/graphical
    ../../suites/desktop
    ../../profiles/home-manager
    ../../profiles/nix
    ../../profiles/sudo
    ../../profiles/tailscale
    ../../profiles/wayland/wlroots.nix
    ../../profiles/wayland/cage/emacs.nix
    ../../profiles/wayland/cage/foot.nix
    ../../profiles/wayland/cage/firefox.nix
    ../../profiles/nix/cachix-deploy.nix
  ];

  system.stateVersion = "22.11";
  disko.devices = import ./disko.nix {};

  networking = {
    firewall.enable = true;
    useDHCP = false;
    networkmanager.enable = true;
  };

  hardware.opengl.enable = true;

  # systemd.services.NetworkManager-wait-online.enable = true;

  services.journald.extraConfig = ''
    SystemMaxFiles=5
  '';

  services.auto-cpufreq.enable = true;

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
      # "docker"
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
    programs.emacs-twist = {
      enable = true;
      emacsclient.enable = true;
      directory = ".local/share/emacs";
      earlyInitFile = emacs-config.outPath + "/emacs/early-init.el";
      config = emacs-config.packages.${pkgs.system}.emacs-config.override {
        extraFeatures = [
          "mermaid"
          "OCaml"
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
