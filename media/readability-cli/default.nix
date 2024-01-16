{pkgs}: let
  inherit (pkgs) lib stdenv;

  composition = pkgs.callPackage ./composition.nix {
    inherit (pkgs) system;
    nodejs = pkgs.nodejs-18_x;
  };

  readability =
    composition
    .readability-cli
    .override (old: {
      nativeBuildInputs =
        (old.nativeBuildInputs or [])
        ++ [
          pkgs.pkg-config
          # composition.node-pre-gyp
        ];
      buildInputs =
        (old.buildInputs or [])
        # These dependencies are required by
        # https://github.com/Automattic/node-canvas. See
        # https://github.com/NixOS/nixpkgs/blob/64ada30bd5dd46b9142181b05ce18ba6889986c9/pkgs/development/node-packages/overrides.nix#L410
        ++ [
          pkgs.giflib
          pkgs.pixman
          pkgs.cairo
          pkgs.pango
        ]
        ++ lib.optionals stdenv.isDarwin [
          pkgs.darwin.apple_sdk.frameworks.CoreText
        ];
    });
in
  pkgs.runCommandLocal "readable"
  {
    propagateBuildInputs = [readability];
  } ''
    mkdir -p $out/bin
    ln -s ${readability}/bin/readable $out/bin/readable
  ''
