{
  pkgs,
  config,
  ...
}:
{
  boot.extraModulePackages = [
    (config.boot.kernelPackages.r8168.overrideAttrs (
      import ../../modules/overrides/r8168.nix { inherit pkgs; }
    ))
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = true;
    timeout = 3;
  };

  boot.kernelParams = [ "ip=dhcp" ];

  boot.supportedFilesystems = [
    "zfs"
    "btrfs"
    "ext4"
  ];

  boot.initrd = {
    enable = true;

    supportedFilesystems = [
      "zfs"
      "btrfs"
      "ext4"
    ];

    availableKernelModules = [
      "xhci_pci"
      "r8169"
      # To temporarily access removable USB storage devices
      "uas"
      "sd_mod"
    ];

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
        zpool import storage1
        echo "zfs load-key -r storage1; /bin/cryptsetup-askpass" >> /root/.profile
      '';
    };
  };

  boot.tmp = {
    tmpfsSize = "1G";
    useTmpfs = true;
  };

  boot.zfs = {
    # The default is true, but it is highly recommended to turn it off for
    # increased reliability.
    forceImportRoot = false;
  };
}
