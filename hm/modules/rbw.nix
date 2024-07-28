{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.rbw.enable {
    programs.rbw = {
      settings = {
        base_url = "http://localhost:8222";
        pinentry = pkgs.pinentry-gtk2;
        email = "akira.komamura@gmail.com";
        lock_timeout = 900;
      };
    };
  };
}
