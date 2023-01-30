{lib}: let
  dir = ./modules;
in
  lib.pipe (builtins.readDir dir) [
    (lib.filterAttrs (_: type: type == "regular"))
    builtins.attrNames
    (builtins.filter (lib.hasSuffix ".nix"))
    (builtins.map (filename: dir + "/${filename}"))
  ]
