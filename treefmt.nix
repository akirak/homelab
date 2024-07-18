{
  projectRootFile = "treefmt.nix";
  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    shellcheck.enable = true;
    yamlfmt.enable = true;
  };

  settings.formatter = {
    shellcheck.includes = [
      "*.sh"
      "*.bash"
      # Don't include .envrc
    ];
  };
}
