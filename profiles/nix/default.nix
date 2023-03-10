/*
   Nix options for desktop machines

If you don't build Nix on the host, don't import this profile.
*/
{
  nix = {
    gc = {
      dates = "2weeks";
      automatic = true;
    };
    optimise.automatic = false;

    settings = {
      # sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel"];

      substituters = [
        "https://cache.nixos.org/"
        "https://akirak.cachix.org"
      ];

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://emacs-ci.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "akirak.cachix.org-1:WJrEMdV1dYyALkOdp/kAECVZ6nAODY5URN05ITFHC+M="
        "emacs-ci.cachix.org-1:B5FVOrxhXXrOL0S+tQ7USrhjMT5iOPH+QN9q0NItom4="
      ];
    };

    extraOptions = ''
      # min-free = 536870912
      # keep-outputs = true
      # keep-derivations = true
      # fallback = true
      experimental-features = nix-command flakes
    '';
  };
}
