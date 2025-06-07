{
  homeUser,
  lib,
  config,
  ...
}: let
  groupName = homeUser;
in {
  users = {
    users.${homeUser}.group = groupName;

    groups.${groupName}.gid = lib.mkDefault config.users.users.${homeUser}.uid;
  };
}
