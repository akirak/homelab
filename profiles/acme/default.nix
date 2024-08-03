{ config, lib, ... }:
let
  defaultEmail = "akira.komamura@gmail.com";
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = defaultEmail;
  };

  users.users.nginx = lib.mkIf config.services.nginx.enable { extraGroups = [ "acme" ]; };
}
