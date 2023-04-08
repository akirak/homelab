{lib, ...}: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        # Explicitly select unfree packages.
        "wpsoffice"
        "steam-run"
        "steam-original"
        "symbola"
        "vscode"
        "microsoft-edge-stable"
      ];
  };
}
