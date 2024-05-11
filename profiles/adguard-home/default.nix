{
  lib,
  config,
  ...
}: let
  dnsmasq = config.services.dnsmasq;
in {
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      dhcp = {
        enabled = false;
      };
      dns =
        {
          port = 53;
          bootstrap_dns = [
            # Cloudflare
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
        // lib.optionalAttrs dnsmasq.enable {
          local_domain_name = dnsmasq.settings.domain;
          upstream_dns = [
            "127.0.0.1:${builtins.toString dnsmasq.settings.port}"
          ];
        };
    };
  };
}
