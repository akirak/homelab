{ config, pkgs, ... }:
let
  domain = "nicesunny.day";

  credentialsPath = "nicesunny.day.credentials.txt";
in
{
  imports = [ ./. ];

  age.secrets = {
    ${credentialsPath} = {
      rekeyFile = ./secrets/nicesunny.day.credentials.txt.age;
      # path = "/etc/acme/secrets/nicesunnyday.txt";
      # mode = "";
      # owner = "";
      # group = "";
    };
  };

  security.acme.certs.${domain} = {
    inherit domain;
    extraDomainNames = [ "*.${domain}" ];
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    # We don't need to wait for propagation since this is a local DNS server
    dnsPropagationCheck = false;
    environmentFile = config.age.secrets.${credentialsPath}.path;
  };

  services.caddy = {
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
      ];
      hash = "sha256-WGV/Ve7hbVry5ugSmTYWDihoC9i+D3Ct15UKgdpYc9U=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    '';
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = [
      config.age.secrets.${credentialsPath}.path
    ];
  };
}
