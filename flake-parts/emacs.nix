{ inputs, ... }:
{
  flake = {
    nixosModules = {
      twistHomeModule =
        { homeUser, ... }:
        {
          home-manager.users.${homeUser} = {
            imports = [ inputs.emacs-config.homeModules.twist ];
          };
        };
    };
  };
}
