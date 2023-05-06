{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.programs.git;
  enabled = cfg.enable;
  personalUser = "Akira Komamura";
  personalEmail = "akira.komamura@gmail.com";
  personalConfig = pkgs.writeText "config" ''
    [user]
    name = ${personalUser}
    email = ${personalEmail}
  '';
in {
  options.programs.git = {
    defaultToPersonalIdentity = mkOption {
      type = types.bool;
      description = "Whether to set the identity to the personal one";
      default = false;
    };
  };

  config = {
    programs.git = {
      userName = lib.mkIf cfg.defaultToPersonalIdentity personalUser;
      userEmail = lib.mkIf cfg.defaultToPersonalIdentity personalEmail;

      delta.enable = true;

      extraConfig = lib.mkIf enabled {
        github.user = lib.mkDefault "akirak";

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
          path = personalConfig;
          condition = "hasconfig:remote.*.url:git@git.sr.ht:~akirak/**";
        }
        {
          path = personalConfig;
          condition = "hasconfig:remote.*.url:https://git.sr.ht/~akirak/**";
        }
        {
          path = personalConfig;
          condition = "gitdir:~/work2/foss/";
        }
        {
          path = personalConfig;
          condition = "gitdir:~/work2/personal/";
        }
        {
          path = personalConfig;
          condition = "gitdir:~/work2/prototypes/";
        }
        {
          path = personalConfig;
          condition = "gitdir:/assets/";
        }
        {
          path = personalConfig;
          condition = "gitdir:/git-annex/";
        }
      ];
    };
  };
}
