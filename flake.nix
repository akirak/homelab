{
  inputs = {
    # From the registry
    nixpkgs.url = "stable";
    unstable.url = "unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    unstable,
    flake-parts,
    nixos-generators,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Use nixos-generators to bootstrap
        packages.sd-image-zhuang = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            ./config/hosts/zhuang/initial.nix
          ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.colmena
          ];
        };
      };

      flake = {
        nixosConfigurations = {
          hcloud-basic = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./config/profiles/hcloud.nix
              {
                networking.hostName = "default";
                # networking.firewall.enable = true;
                services.tailscale.enable = true;
                networking.firewall.trustedInterfaces = ["tailscale0"];
                nix.allowedUsers = ["root"];

                users.users.root = {
                  hashedPassword = "$y$j9T$/p0sG9urgKkB6o.1IYunU/$iueghwqXj9mxDPP9fVu36NeNvvVdf.tdSchG2ZK5WT1";
                  # Allow root login only with my PGP card
                  openssh.authorizedKeys.keys = [
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEHKzdRvr0KjzLNGVV7eNcjh0m8liuXR2JLj2UA0Qa0yep3yZuVEc/I3l57z4FF27YvFVgxhLAAzXupeI98l3QTYXfaL4SF64/IZHElSC4pH5hHNNDMF37DCVLBAeAxesSkqhVoUMsG8lDiLSHy24GQBt9mKxFk461eViyVxLnPwzs7NsDo2sKVLFkPIG+SFI9wFrvRZK30l/twgljNefSoJc5xlIr6XXme3rKp00T4DMPb2sC2a9yYG5SgihQuB1RJkPXrp1gvp0wD1vc+lmniGiJEWbSefq3Ntaue48+o+yMgnazCQXSc/ozxmoK2ZISztEW+CBk5V9uD9TU8w5V cardno:11 482 161"
                  ];
                };
                time.timeZone = "Asia/Tokyo";
                system.stateVersion = "22.11";

                networking.firewall.allowedTCPPorts = [
                  80
                  443
                ];

                services.nginx = {
                  enable = true;
                };

                # https://xeiaso.net/blog/paranoid-nixos-2021-07-18
                services.openssh = {
                  enable = true;
                  passwordAuthentication = false;
                  allowSFTP = false;
                  challengeResponseAuthentication = false;
                  extraConfig = ''
                    AllowTcpForwarding yes
                    X11Forwarding no
                    AllowAgentForwarding no
                    AllowStreamLocalForwarding no
                    AuthenticationMethods publickey
                  '';
                };
              }
            ];
          };
        };

        colmena = {
          meta = {
            nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
            specialArgs = {
              inherit unstable;
            };
          };

          zhuang = {
            deployment = {
              # A fixed IP address is configured in the router
              targetHost = "192.168.0.60";
              targetPort = 2022;
              targetUser = "root";
            };
            nixpkgs.system = "aarch64-linux";
            imports = [
              <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
              ./config/hosts/zhuang/initial.nix
              ./config/hosts/zhuang/rest.nix
            ];
          };
        };
      };
    };
}
