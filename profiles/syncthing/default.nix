{ lib, config, ... }:
let
  inherit (builtins) toString;

  cfg = config.services.syncthing;

  devices = lib.pipe (lib.importTOML ../../machines/metadata.toml).hosts [
    (lib.filterAttrs (_: attrs: attrs ? syncthingId))
    (builtins.mapAttrs (_: attrs: { id = attrs.syncthingId; }))
  ];

  inherit (config.networking) hostName;

  otherDevicesByHostName = lib.remove hostName;

  allDevices = otherDevicesByHostName (builtins.attrNames devices);

  enableReverseProxy = config.services.reverse-proxy.enable;

  guiPort = 8384;
in
{
  services.syncthing = {
    enable = true;
    # Just the default dataDir. This needs to be on a dedicated ZFS dataset.
    dataDir = "/var/lib/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    openDefaultPorts = true;
    guiAddress =
      if enableReverseProxy then "127.0.0.1:${toString guiPort}" else "0.0.0.0:${toString guiPort}";
    settings = {
      devices = lib.filterAttrs (name: _: name != hostName) devices;
      folders = {
        "org" = {
          path = cfg.dataDir + "/org";
          devices = allDevices;
          id = "v3msx-gwdqt";
        };
        "notes-and-pdfs" = {
          path = cfg.dataDir + "/notes-and-pdfs";
          devices = otherDevicesByHostName [
            "li"
          ];
          id = "4warh-yejmn";
        };
        "private" = {
          path = cfg.dataDir + "/private";
          devices = otherDevicesByHostName [
            "li"
            "yang"
          ];
          id = "gstwc-lxb3v";
        };
      };
      # Prevent "Host check error"
      # https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api
      gui.insecureSkipHostCheck = lib.mkIf enableReverseProxy true;

      # Wait for the PR
      # gui.user = "akirak";
      # inherit guiPasswordFile;
    };
  };

  services.reverse-proxy = lib.mkIf enableReverseProxy {
    subdomains.syncthing = {
      reverse-proxy = "localhost:${toString guiPort}";
    };
  };

  # The other ports are opened via openDefaultPorts, so only the web port needs
  # to be explicitly opened.
  networking.firewall = lib.mkIf (config.networking.firewall.enable && !enableReverseProxy) {
    allowedTCPPorts = [ 8384 ];
  };

  # The password is unencrypted, so it's basically useless. Wait for the PR on
  # guiPasswordFile option to get merged.

  # services.syncthing.settings.gui = {
  #   user = "akirak";
  #   password = "$2y$10$epya6R5qrkZzGGCUZFQ5duA9NBvPesWkNp1QBnyJE8JWp1zenEEdq";
  # };
}
