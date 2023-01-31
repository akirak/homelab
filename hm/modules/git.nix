{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.git;
  enabled = cfg.enable;
  default-identity = pkgs.writeText "config" ''
    [user]
    name = Akira Komamura
    email = akira.komamura@gmail.com
  '';
in {
  programs.git = {
    extraConfig = lib.mkIf enabled {
      github.user = "akirak";

      pull.rebase = false;

      "url \"git@github.com:\"".pushInsteadOf = "https://github.com/";
      "url \"git@git.sr.ht:\"".pushInsteadOf = "https://git.sr.ht/";

      core.autocrlf = "input";

      # Only on WSL
      # core.fileMode = false;

      # Increase the size of post buffers to prevent hung ups of git-push.
      # https://stackoverflow.com/questions/6842687/the-remote-end-hung-up-unexpectedly-while-git-cloning#6849424
      http.postBuffer = "524288000";
    };

    ignores = lib.mkIf enabled [
      ".direnv"
      "result"
      "result-*"
      "#*"
    ];

    # Include configuration files to activate contextual identities
    includes = lib.mkIf enabled [
      {
        path = "~/.gitconfig";
      }
      {
        path = default-identity;
        condition = "hasconfig:remote.*.url:git@git.sr.ht:~akirak/**";
      }
      {
        path = default-identity;
        condition = "hasconfig:remote.*.url:https://git.sr.ht/~akirak/**";
      }
      {
        path = default-identity;
        condition = "gitdir:~/work2/foss/";
      }
      {
        path = default-identity;
        condition = "gitdir:~/work2/personal/";
      }
      {
        path = default-identity;
        condition = "gitdir:~/work2/prototypes/";
      }
      {
        path = default-identity;
        condition = "gitdir:/assets/";
      }
      {
        path = default-identity;
        condition = "gitdir:/git-annex/";
      }
    ];
  };
}