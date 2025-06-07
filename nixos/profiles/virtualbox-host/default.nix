{pkgs, ...}: let
  virtualboxDesktopItemsGenerator = pkgs.writeShellApplication {
    name = "virtualbox-generate-desktop-items";

    text = builtins.readFile ./generate.bash;
  };
in {
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  environment.systemPackages = [
    virtualboxDesktopItemsGenerator
  ];
}
