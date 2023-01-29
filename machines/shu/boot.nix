{config, ...}: let
  cryptName = "cryptroot";
  cryptDevice = "/dev/sda3";
in {
  boot.kernelModules = ["virtio_net"];
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd = {
    enable = true;

    # Network card drivers.
    kernelModules = ["virtio_net"];

    luks.devices.${cryptName} = {
      device = cryptDevice;
      allowDiscards = true;
    };

    network = {
      enable = true;

      ssh = {
        enable = true;
        port = 222;

        hostKeys = [
          "/persist/boot_ed25519_key"
        ];

        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      };
    };
  };

  networking = {
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  boot.supportedFilesystems = ["zfs"];
  boot.initrd.supportedFilesystems = ["zfs"];
  boot.zfs.requestEncryptionCredentials = true;
  boot.kernelParams = ["zfs.zfs_arc_max=805306368"];
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
}
