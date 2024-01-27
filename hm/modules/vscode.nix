{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.vscode;
  exts = pkgs.vscode-extensions;
in {
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enableExtensionUpdateCheck = true;
      extensions = [
        exts.github.copilot
        exts.github.copilot-chat
        exts.mkhl.direnv
      ];
    };
  };
}
