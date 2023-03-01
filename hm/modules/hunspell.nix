{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (builtins) listToAttrs concatLists map;

  cfg = config.i18n.spell;

  links = pkgs.symlinkJoin {
    name = "hunspell-dicts";
    paths = cfg.hunspellDicts pkgs.hunspellDicts;
  };
in {
  options = {
    i18n.spell.hunspellDicts = mkOption {
      type = types.nullOr (types.functionTo (types.listOf types.package));
      default = null;
      description = lib.mdDoc "List of hunspell dictionary";
      example = "hd: [ hd.en_US ]";
    };
  };

  config = mkIf (cfg.hunspellDicts != null) {
    xdg.dataFile."hunspell".source = links + "/share/hunspell";
    xdg.dataFile."hunspell".recursive = true;

    xdg.dataFile."myspell/dicts".source = links + "/share/myspell/dicts";
    xdg.dataFile."myspell/dicts".recursive = true;
  };
}
