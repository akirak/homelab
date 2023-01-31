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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${homeUser} = {
      imports = [
        ../../hm
      ];

      home.stateVersion = config.system.stateVersion;
    };
  };
}
