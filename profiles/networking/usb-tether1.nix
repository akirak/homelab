{
  systemd.network.links."20-usb1" = {
    matchConfig = {
      Driver = "rndis_host";
    };
    linkConfig = {
      Name = "usb1";
    };
  };
}
