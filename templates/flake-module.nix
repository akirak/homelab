{
  flake = {
    # Templates can be defined only once
    templates = {
      home-manager = {
        path = ./home-manager;
        description = "An example configuration repository for home-manager";
      };
      nixos-wsl = {
        path = ./nixos-wsl;
        description = "An example configuration flake for NixOS-WSL";
      };
    };
  };
}
