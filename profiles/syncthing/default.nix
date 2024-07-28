{ lib, config, ... }:
let
  cfg = config.services.syncthing;

  devices = {
    li = {
      id = "UTRWWS3-XAUUIAV-7DAM6RM-5N4LDSS-D27MPMQ-ERVPJER-VXB4YPJ-K3L23Q5";
    };
  };

  inherit (config.networking) hostName;

  excludeThisDevice = lib.remove hostName;

  allDevices = excludeThisDevice (builtins.attrNames devices);
in
{
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    settings = {
      devices = lib.filterAttrs (name: _: name != hostName) devices;
      folders = {
        "org" = {
          path = cfg.dataDir + "/org";
          devices = allDevices;
          id = "qv34o-qzgf6";
        };
        "private" = {
          path = cfg.dataDir + "/private";
          devices = excludeThisDevice [
            "li"
            "yang"
          ];
          id = "oyzfe-oidou";
        };
      };
    };
  };

  # The other ports are opened via openDefaultPorts, so only the web port needs
  # to be explicitly opened.
  networking.firewall = lib.mkIf config.networking.firewall.enable { allowedTCPPorts = [ 8384 ]; };

  services.syncthing.settings.gui = {
    user = "akirak";
    password = "$2y$10$epya6R5qrkZzGGCUZFQ5duA9NBvPesWkNp1QBnyJE8JWp1zenEEdq";
  };
}
