{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "fzy-zfs-mount";
      runtimeInputs = [
        pkgs.fzy
      ];
      text = ''
        if fs=$(zfs list -Hp | cut -d $'\t' -f1 | fzy)
        then
          zfs mount "$fs"
          findmnt "$fs"
        fi
      '';
    })
  ];
}
