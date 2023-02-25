/*
Default integration with home-manager

You also have to import home-manager.nixosModules.home-manager
*/
{
  homeUser,
  config,
  ...
}: {
  imports = [
    ../nixpkgs/channels.nix
  ];

  users.defaultUserShell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${homeUser} = {
      imports = [
        ../../hm
      ];

      programs.nixos-rebuild-and-notify.enable = true;

      home.stateVersion = config.system.stateVersion;
    };
  };
}
