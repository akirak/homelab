{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      dhcp = {
        enabled = false;
      };
      dns = {
        # Use the AdguardHome DNS only for external traffic
        port = 5353;
        bootstrap_dns = [
          # Cloudflare
          "1.1.1.1"
          "1.0.0.1"
        ];
        upstream_dns = [
          "1.1.1.1"
          "8.8.8.8"
          "9.9.9.9"
        ];
        upstream_mode = "fastest_addr";
      };
    };
  };
}
