{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.password-store;

  agePackage = pkgs.rage;

  passageRoot = "${config.home.homeDirectory}/secrets";

  # A wrapper for the steps described in https://github.com/FiloSottile/passage
  # for multiple YubiKey support
  passage-yubikey-update = pkgs.writeShellApplication {
    name = "passage-yubikey-update";
    runtimeInputs = [
      pkgs.age-plugin-yubikey
    ];
    text = ''
      if ! [[ -d "${cfg.settings.PASSAGE_DIR}" ]]; then
        echo >&2 "Error: ${cfg.settings.PASSAGE_DIR} must be created manually."
        exit 1
      fi

      identitiesFile="${cfg.settings.PASSAGE_IDENTITIES_FILE}"
      recipientsFile="${cfg.settings.PASSAGE_RECIPIENTS_FILE}"

      mkdir -p "$(dirname "$identitiesFile")"
      mkdir -p "$(dirname "$recipientsFile")"

      age-plugin-yubikey --identity >> "$identitiesFile"
      echo >&2 "Updated $identitiesFile"

      age-plugin-yubikey --list >> "$recipientsFile"
      echo >&2 "Updated $recipientsFile"
    '';
  };
in
{
  programs.password-store = {
    package = pkgs.passage;
    settings = {
      PASSAGE_DIR = "${passageRoot}/store";
      PASSAGE_AGE = lib.getExe agePackage;
      PASSAGE_IDENTITIES_FILE = "${passageRoot}/identities";
      PASSAGE_RECIPIENTS_FILE = "${passageRoot}/store/.age-recipients";
    };
  };

  home.packages = [
    passage-yubikey-update
  ];
}
