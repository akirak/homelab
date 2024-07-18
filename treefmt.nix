{
  projectRootFile = "treefmt.nix";
  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    shellcheck.enable = true;
    yamlfmt.enable = true;
  };

  settings.formatter = {
    shellcheck.excludes = [
      ".envrc"
    ];
  };
}
