{pkgs, ...}: {
  imports = [
    ../wlroots.nix
    ../sessions.nix
  ];

  environment.systemPackages = [
    # riverctl and rivertile need to be in PATH
    pkgs.river

    (pkgs.writeShellScriptBin "river-session" ''
      export XKB_DEFAULT_LAYOUT=us
      export XKB_DEFAULT_OPTIONS=ctrl:nocaps
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=sway
      export XDG_CURRENT_DESKTOP=sway
      export MOZ_ENABLE_WAYLAND=1
      # Set SWAYSOCK to use swaymsg and other sway-compatible utilities
      export SWAYSOCK=''${XDG_RUNTIME_DIR}/wayland-1
      exec ${pkgs.dbus}/bin/dbus-run-session -- river
    '')
  ];

  wayland.sessions = [
    {
      name = "river-session";
    }
  ];
}
