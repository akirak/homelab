# Flake Template for NixOS-WSL

This is a flake template for quickly setting up my custom NixOS environment for
development on Windows Subsystem for Linux.

## How to use

First follow [the
instruction](https://github.com/nix-community/NixOS-WSL?tab=readme-ov-file#quick-start)
to create a NixOS container.

``` shell
nix-shell -p git
alias nix='nix --extra-experimental-features nix-command --extra-experimental-features flakes'
nix flake new -t github:akirak/homelab#nixos-wsl ~/config-local
cd ~/config-local
git init
git add flake.nix
```

Tweak `flake.nix` as needed and run:

``` shell
# Make `just` available
nix develop
# Run nixos-rebuild build
just build
# Run nixos-rebuild switch
just switch
```
