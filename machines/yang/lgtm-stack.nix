# Configuration of the LGTM (Logs, Grafana, Traces, and Metrics) stack
#
# This configuration is mostly based on the following resources:
#
# https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
# https://gist.github.com/rickhull/895b0cb38fdd537c1078a858cf15d63e
{ config, ... }:
let
  grafanaSettings = config.services.grafana.settings;

  prometheusExporters = config.services.prometheus.exporters;

  domain = "nicesunny.day";
in
{
  services.caddy = {
    enable = true;
    virtualHosts."grafana.${domain}" = {
      useACMEHost = domain;
      # TODO: Set Host header to the server domain?
      # Proxy web sockets
      extraConfig = ''
        reverse_proxy localhost:${toString grafanaSettings.server.http_port}
      '';
    };
    virtualHosts."grafana:80" = {
      extraConfig = ''
        redir https://grafana.${domain}
      '';
    };
  };

  # Set the domain to avoid "Origin not allowed" error.
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.${domain}";
      http_port = 2342;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node-localhost";
        static_configs = [ { targets = [ "127.0.0.1:${toString prometheusExporters.node.port}" ]; } ];
      }
    ];
  };
}
