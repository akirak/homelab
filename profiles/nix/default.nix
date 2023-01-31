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
