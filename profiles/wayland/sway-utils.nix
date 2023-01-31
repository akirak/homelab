{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellApplication {
      name = "lock-screen";
      runtimeInputs = [pkgs.swaylock-effects];
      # TODO: Use a color scheme
      text = ''
        swaylock -f --clock --fade-in 0.5
      '';
    })

    # screenshot and screen recording
    wayshot
    wf-recorder
    slurp # Used with wayshot

    wofi
  ];
}
