/*
Default integration with home-manager

You also have to import home-manager.nixosModules.home-manager
*/
{
  homeUser,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../nixpkgs/channels.nix
  ];

  users.defaultUserShell =
    if config.programs.zsh.enable
    then pkgs.zsh
    else pkgs.bash;

  programs.zsh.enable = true;

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
