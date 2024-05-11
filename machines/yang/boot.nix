{config, ...}: {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = true;
    timeout = 3;
  };

  boot.kernelParams = ["ip=dhcp"];

  boot.supportedFilesystems = [
    "zfs"
    "btrfs"
  ];

  boot.initrd = {
    enable = true;

    supportedFilesystems = [
      "zfs"
      "btrfs"
    ];

    availableKernelModules = [
      "xhci_hcd"
      "r8169"
    ];

    # systemd.users.root.shell = "/bin/cryptsetup-askpass";

    network = {
      enable = true;

      ssh = {
        enable = true;
        port = 222;

        hostKeys = [
          # Generate a key pair using ssh-keygen
          "/persist/initrd-ssh-hostkey"
        ];

        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      };

      postCommands = ''
        zpool import rpool4
        echo "zfs load-key -r rpool4; /bin/cryptsetup-askpass" >> /root/.profile
      '';
    };
  };

  boot.zfs = {
    # The default is true, but it is suggested to turn it off.
    forceImportRoot = false;
  };

  networking = {
    useDHCP = true;
  };
}
