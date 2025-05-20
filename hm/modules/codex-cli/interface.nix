{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.codex-cli;

  inherit (lib) mkOption mkEnableOption types;

  wrapped = cfg.package.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkgs.makeWrapper
    ];
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
      cfg.age.package
    ];
    # Store one or more multiple --api-key options in an age-encrypted
    # file and decrypt the content when the program starts.
    postInstall = ''
      wrapProgram $out/bin/codex \
        --inherit-argv0 \
        --run 'export $(${lib.getExe cfg.age.package} \
          -i ${cfg.age.identityFile} \
          --decrypt ${cfg.age.envFile})'
    '';
  });
in
{
  options = {
    programs.codex-cli = {
      enable = mkEnableOption (lib.mdDoc "Whether to install a custom wrapped version of codex-cli");

      package = mkOption {
        type = types.package;
        description = lib.mdDoc "codex-cli package";
      };

      age = {
        package = mkOption {
          type = types.package;
          description = lib.mdDoc "age package";
          default = pkgs.age;
        };

        envFile = mkOption {
          type = types.path;
          description = lib.mdDoc "Path to an age-encrypted secret";
        };

        identityFile = mkOption {
          type = types.path;
          description = lib.mdDoc "Path to an identity file";
        };
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable [
      wrapped
    ];
  };
}
