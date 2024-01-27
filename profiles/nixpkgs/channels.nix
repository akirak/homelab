{lib, ...}: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: let
      name = lib.getName pkg;
    in
      builtins.elem name [
        # Explicitly select unfree packages.
        "wpsoffice"
        "steam-run"
        "steam-original"
        "symbola"
        "vscode"
        "microsoft-edge-stable"
        "android-studio-stable"
        "zoom"
        "Oracle_VM_VirtualBox_Extension_Pack"
        "vscode-extension-github-copilot"
        "vscode-extension-github-copilot-chat"
      ];
  };
}
