{ lib, pkgs, ... }:
let
  # Build an interpreter-only derivation for running a package directly.
  onlySingleBin =
    drv: name:
    (pkgs.callPackage (
      { runCommand, makeWrapper }:
      runCommand name
        {
          buildInputs = [
            makeWrapper
          ];
          propagatedBuildInputs = [ drv ];
        }
        ''
          mkdir -p $out/bin
          makeWrapper ${lib.getExe' drv name} $out/bin/${name} \
            --prefix PATH : ${lib.getBin drv}/bin
        ''
    ) { });
in
{
  home.packages = with pkgs; [
    yamlfmt
    vscode-langservers-extracted # Primarily for the JSON server
    nil # Nix

    # AI
    aider-chat

    # Used to run MCP servers.
    (onlySingleBin pkgs.nodejs "npx")
    (onlySingleBin pkgs.uv "uvx")
  ];
}
