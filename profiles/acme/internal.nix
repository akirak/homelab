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
    dnsPropagationCheck = true;
    environmentFile = config.age.secrets."nicesunny.day.credentials.txt".path;
  };
}
