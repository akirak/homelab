{
  config,
  lib,
  ...
}: let
  cfg = config.programs.gpg;
in {
  services.gpg-agent = lib.mkIf cfg.enable {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    defaultCacheTtlSsh = 60;
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
    # pinentryFlavor = "gtk2";
    sshKeys = [
      "5B3390B01C01D3EE"
    ];
  };

  programs.bash.initExtra = lib.mkIf cfg.enable ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  programs.git.signing.key = lib.mkIf cfg.enable "5B3390B01C01D3E";
}
