{ pkgs, ... }:
_: super: rec {
  version = "8.054.00";
  src = pkgs.fetchFromGitHub {
    owner = "mtorromeo";
    repo = "r8168";
    rev = version;
    sha256 = "sha256-KyycAe+NBmyDDH/XkAM4PpGvXI5J1CuMW4VuHcOm0UQ=";
  };
  meta = super.meta // {
    broken = false;
  };
}
