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
        "android-studio-stable"
        "zoom"
        "Oracle_VM_VirtualBox_Extension_Pack" # older
        "Oracle_VirtualBox_Extension_Pack" # newer
        "google-chrome"
        "intel-ocl"
<<<<<<< HEAD
||||||| parent of 4fddacc (machines/li: Add stream-run package)
        "cursor"
=======
        "cursor"
        "steam-unwrapped"
>>>>>>> 4fddacc (machines/li: Add stream-run package)
      ];
  };
}
