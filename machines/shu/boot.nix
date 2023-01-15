{config, ...}:
let
  cryptName = "cryptroot";
  cryptDevice = "/dev/sda3";
  in
{
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

      # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030/3
      postCommands = ''
        echo "cryptsetup-askpass" >> /root/.profile
      '';
    };
  };

  networking = {
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };
}
