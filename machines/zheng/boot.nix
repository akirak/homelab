{
  pkgs,
  config,
  ...
}: let
  staticIp = "192.168.0.61";
  initialSshPort = 222;
  stage1Modules = [
    "uas"
    "genet"
  ];
in {
  boot.kernelModules = stage1Modules;

  boot.initrd = {
    enable = true;

    availableKernelModules = [
      "pcie-brcmstb"
      "reset-raspberrypi"
    ];

    kernelModules = stage1Modules;

    luks.devices.cryptroot = {
      allowDiscards = true;
    };

    network = {
      enable = true;

      # https://github.com/NixOS/nixpkgs/issues/98741
      postCommands = ''
        until ip link set eth0 up; do sleep .1; done
        ip addr add ${staticIp} dev eth0
        ip route add default via ${staticIp} dev eth0
      '';

      ssh = {
        enable = true;
        port = initialSshPort;

        hostKeys = [
          "/etc/ssh/boot_ed25519_key"
        ];

        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      };
    };
  };

  networking = {
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  # Use a bootloader that supports initrd secrets.
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
  };
  # Override the default of the rpi4 hardware module.
  boot.loader.generic-extlinux-compatible.enable = false;
}
