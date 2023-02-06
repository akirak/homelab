{config, ...}: let
  cfg = config.services.pleroma;

  user = cfg.user;
  group = cfg.group;
in {
  services.pleroma = {
    enable = true;
    user = "pleroma";
    group = "pleroma";
    configs = [
      ./config/default.exs
    ];
  };

  users.users.${user} = {
    isSystemUser = true;
    extraGroups = [
      group
    ];
    uid = 600;
  };

  users.groups.${group} = {
    gid = 600;
  };
}
