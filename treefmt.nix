{
  projectRootFile = "treefmt.nix";
  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    shellcheck.enable = true;
  };

  settings.formatter = {
    alejandra.excludes = [
      "pkgs/generate/node2nix/*.nix"
    ];
    deadnix.excludes = [
      "pkgs/generate/node2nix/*.nix"
    ];
  };
}
