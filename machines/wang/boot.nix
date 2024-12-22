{ pkgs, config, ... }:
{
  boot.extraModulePackages = [
    (config.boot.kernelPackages.r8168.overrideAttrs (import ../overrides/r8168.nix { inherit pkgs; }))
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = true;
    timeout = 3;
  };

  boot.kernelParams = [ "ip=dhcp" ];

  boot.supportedFilesystems = [
    # "zfs"
    "btrfs"
  ];

  boot.initrd = {
    enable = true;

    supportedFilesystems = [
      # "zfs"
      "btrfs"
    ];

    availableKernelModules = [
      "xhci_pci"
      "r8169"
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
        echo "/bin/cryptsetup-askpass" >> /root/.profile
      '';

      # postCommands = ''
      #   zpool import rpool6
      #   echo "zfs load-key -r rpool6; /bin/cryptsetup-askpass" >> /root/.profile
      # '';
    };
  };

  # boot.zfs = {
  #   # The default is true, but it is suggested to turn it off.
  #   forceImportRoot = false;
  # };
}
