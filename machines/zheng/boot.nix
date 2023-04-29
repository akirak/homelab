{
  pkgs,
  config,
  ...
}: let
  staticIp = "192.168.2.1";
  initialSshPort = 222;
  stage1Modules = [
    "uas"
    "genet"
  ];
in {
  boot.kernelModules = stage1Modules;

  hardware.deviceTree = {
    filter = "bcm2711-rpi-4-b.dtb";
    kernelPackage = pkgs.linux_rpi4;
  };
  hardware.enableRedistributableFirmware = true;

  boot.initrd = {
    enable = true;

    availableKernelModules = [
      "pcie-brcmstb"
      "reset-raspberrypi"
    ];

    kernelModules = stage1Modules;

    luks.devices.cryptcorsair1 = {
      allowDiscards = true;
    };

    network = {
      enable = true;

      # https://github.com/NixOS/nixpkgs/issues/98741
      postCommands = ''
        until ip link set eth0 up; do sleep .1; done
        ip addr add ${staticIp} dev eth0
        # ip route add default via ${staticIp} dev eth0
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
    usePredictableInterfaceNames = true;
    dhcpcd.enable = false;

    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "192.168.2.1";
          prefixLength = 16;
        }
      ];
    };
  };

  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "eth0"
    ];
  };

  systemd.network.links."20-tether1" = {
    matchConfig = {
      Driver = "rndis_host";
    };
    linkConfig = {
      Name = "tether1";
    };
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
