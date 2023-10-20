/*
My preferred locale settings
*/
let
  defaultLocale = "en_US.UTF-8";
in {
  i18n = {
    inherit defaultLocale;
    extraLocaleSettings = {
      LC_CTYPE = defaultLocale;
      # LC_COLLATE = "C.UTF-8";
      # LC_TIME = "en_DK.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "zh_TW.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };
}
