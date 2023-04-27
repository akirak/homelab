{ pkgs, homeUser, ...}:
{
  programs.adb.enable = true;
  users.users.${homeUser}.extraGroups = [
    "adbusers"
  ];
  home-manager.users.${homeUser} = {
    home.packages = [
      pkgs.android-studio
    ];
  };
}
