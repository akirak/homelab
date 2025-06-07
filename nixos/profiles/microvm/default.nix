# Based on flake.nix for github:astro/microvm.nix
{
  hypervisor,
  config,
  lib,
  ...
}: let
  inherit (builtins) elem;

  hypervisorsWith9p = ["qemu"];
  hypervisorsWithUserNet = ["qemu" "kvmtool"];
in {
  microvm.hypervisor = hypervisor;

  microvm.shares = lib.optional (elem hypervisor hypervisorsWith9p) {
    tag = "ro-store";
    source = "/nix/store";
    mountPoint = "/nix/.ro-store";
  };
  microvm.writableStoreOverlay = "/nix/.rw-store";
  microvm.volumes = [
    {
      image = "nix-store-overlay.img";
      mountPoint = config.microvm.writableStoreOverlay;
      size = 2048;
    }
  ];

  microvm.interfaces = lib.optional (elem hypervisor hypervisorsWithUserNet) {
    type = "user";
    id = "qemu";
    mac = "02:00:00:01:01:01";
  };
}
