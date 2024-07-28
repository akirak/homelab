{
  projectRootFile = "treefmt.nix";
  programs = {
    nixfmt-rfc-style.enable = true;
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
