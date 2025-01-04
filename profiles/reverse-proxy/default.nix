{ config, lib, ... }:
let
  inherit (lib) types mkOption mkEnableOption;

  cfg = config.services.reverse-proxy;

  httpPort = 80;

  httpsPort = 443;

  subdomainType = types.submodule {
    options.reverse-proxy = mkOption {
      type = types.str;
      example = "localhost:8080";
    };
  };
in
{
  options.services.reverse-proxy = {
    enable = mkEnableOption (lib.mdDoc "Enable a reverse-proxy service for loopback services.");

    domain = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        Public DNS domain on which the services should be served as subdomains.
      '';
    };

    useACMEHost = mkOption {
      type = types.str;
      default = cfg.domain;
      description = lib.mdDoc ''
        ACME host
      '';
    };

    subdomains = mkOption {
      type = types.attrsOf subdomainType;
      description = lib.mdDoc ''
        Subdomains served via the reverse proxy.
      '';
    };
  };

  config = {
    services.caddy = {
      enable = lib.mkIf cfg.enable true;
      virtualHosts = lib.optionalAttrs cfg.enable (
        lib.concatMapAttrs (name: attrs: {
          "${name}.${cfg.domain}" = {
            inherit (cfg) useACMEHost;
            extraConfig = ''
              reverse_proxy ${attrs.reverse-proxy}

              tls {
                dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
                # resolvers 1.0.0.1
              }
            '';
          };
          "${name}:${builtins.toString httpPort}" = {
            extraConfig = ''
              redir https://${name}.${cfg.domain}
            '';
          };
        }) cfg.subdomains
      );
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.enable [
      httpPort
      httpsPort
    ];
  };
}
