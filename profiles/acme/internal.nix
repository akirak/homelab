{ config, ... }:
let
  domain = "nicesunny.day";
in
{
  imports = [ ./. ];

  age.secrets = {
    "nicesunny.day.credentials.txt" = {
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
    environmentFile = config.age.secrets."nicesunny.day.credentials.txt".path;
  };
}
