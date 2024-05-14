{
  config,
  lib,
  ...
}:
# This configuration is mostly based on the following awesome blog post:
# https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md
let
  routerAddress = "192.168.10.1";

  subnet = "192.168.10.0/16";

  modules = [
    "uas"
    "genet"
  ];

  adguardhome = config.services.adguardhome;
in {
  imports = [
    ./usb-wifi.nix
    ../../profiles/adguard-home
  ];

  boot.kernelModules = modules;

  # https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md#kernel
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = false;
    };
  };

  # https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md#interfaces
  systemd.network = {
    wait-online.anyInterface = true;

    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };

    links = {
      # Enable USB tethering.
      "40-usb0" = {
        matchConfig = {
          Driver = "rndis_host";
        };
        linkConfig = {
          Name = "usb0";
        };
      };
    };

    networks = {
      "30-lan0" = {
        matchConfig.Name = "end0";
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
      };
      # There is also a built-in wifi, wlan0, but it doesn't allow enslaving to
      # a bridge.
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = {};
        address = [
          "${routerAddress}/24"
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
      "50-wan" = {
        matchConfig.Name = "usb0";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = false;
          IPForward = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;

    nat.enable = false;
    firewall.enable = false;

    nftables = {
      enable = true;
      # https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router
      ruleset = ''
        define DEV_PRIVATE = br-lan
        define DEV_WORLD = usb0
        define NET_PRIVATE = ${subnet}

        table ip global {

            chain inbound_world {
                # accepting ping (icmp-echo-request) for diagnostic purposes.
                # However, it also lets probes discover this host is alive.
                # This sample accepts them within a certain rate limit:
                #
                # icmp type echo-request limit rate 5/second accept

                # allow SSH connections from some well-known internet host
                # ip saddr 81.209.165.42 tcp dport ssh accept
            }

            chain inbound_private {
                # accepting ping (icmp-echo-request) for diagnostic purposes.
                icmp type echo-request limit rate 5/second accept

                # allow DHCP, DNS and SSH from the private network
                ip protocol . th dport vmap { tcp . 22 : accept, udp . 53 : accept, tcp . 53 : accept, udp . 67 : accept}
            }

            chain inbound {
                type filter hook input priority 0; policy drop;

                # Allow traffic from established and related packets, drop invalid
                ct state vmap { established : accept, related : accept, invalid : drop }

                # allow loopback traffic, anything else jump to chain for further evaluation
                iifname vmap { lo : accept, $DEV_WORLD : jump inbound_world, $DEV_PRIVATE : jump inbound_private }

                # the rest is dropped by the above policy
            }

            chain forward {
                type filter hook forward priority 0; policy drop;

                # Allow traffic from established and related packets, drop invalid
                ct state vmap { established : accept, related : accept, invalid : drop }

                # connections from the internal net to the internet or to other
                # internal nets are allowed
                iifname $DEV_PRIVATE accept

                # the rest is dropped by the above policy
            }

            chain postrouting {
                type nat hook postrouting priority 100; policy accept;

                # masquerade private IP addresses
                ip saddr $NET_PRIVATE oifname $DEV_WORLD masquerade
            }
        }
      '';
    };
  };

  # systemd-resolved listens on port 53, which conflicts with dnsmasq, so
  # disable it.
  services.resolved.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      # upstream DNS servers
      server = ["9.9.9.9" "8.8.8.8" "1.1.1.1"];
      # sensible behaviours
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      resolveLocalQueries = lib.mkIf adguardhome.enable false;
      # Use a port other than 53 if adguard home is running
      port = lib.mkIf adguardhome.enable 5353;

      # Cache dns queries.
      cache-size = 1000;

      dhcp-range = ["br-lan,192.168.10.50,192.168.10.254,24h"];
      interface = "br-lan";
      dhcp-host = routerAddress;
      dhcp-authoritative = true;
      # dhcp-sequential-ip = true;

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts as this would advertise surfer as localhost
      no-hosts = true;
      address = "/zheng.lan/${routerAddress}";
    };
  };

  services.hostapd = {
    enable = true;
    radios = {
      wlp1s0u1u4 = {
        band = "2g";
        countryCode = "JP";
        channel = 8;

        settings.bridge = "br-lan";

        wifi4 = {
          enable = true;
          capabilities = [
            "RX-STBC1"
            "SHORT-GI-40"
            "SHORT-GI-20"
            "DSSS_CCK-40"
            "MAX-AMSDU-7935"
          ];
        };

        networks = {
          wlp1s0u1u4 = {
            ssid = "nicky";
            authentication = {
              mode = "wpa3-sae";
              saePasswordsFile = "/etc/hostapd/password";
            };
          };
        };
      };
    };
  };

  services.adguardhome.settings = lib.mkIf adguardhome.enable {
    dns.bind_hosts = [
      "127.0.0.1"
      "192.168.10.1"
    ];
  };
}
