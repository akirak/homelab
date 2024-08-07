let
  login = "akirakomamura";
  group = login;
in
{
  users = {
    users.${login} = {
      description = "Akira Komamura";
      createHome = true;
      uid = 1000;
      inherit group;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEHKzdRvr0KjzLNGVV7eNcjh0m8liuXR2JLj2UA0Qa0yep3yZuVEc/I3l57z4FF27YvFVgxhLAAzXupeI98l3QTYXfaL4SF64/IZHElSC4pH5hHNNDMF37DCVLBAeAxesSkqhVoUMsG8lDiLSHy24GQBt9mKxFk461eViyVxLnPwzs7NsDo2sKVLFkPIG+SFI9wFrvRZK30l/twgljNefSoJc5xlIr6XXme3rKp00T4DMPb2sC2a9yYG5SgihQuB1RJkPXrp1gvp0wD1vc+lmniGiJEWbSefq3Ntaue48+o+yMgnazCQXSc/ozxmoK2ZISztEW+CBk5V9uD9TU8w5V cardno:11 482 161"
      ];
    };

    groups.${group} = {
      gid = 1000;
    };
  };
}
