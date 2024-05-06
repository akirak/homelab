{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    # Add lshw for ease of debugging. Use `lshw -c network` to find
    # `driver=8192eu`
    pkgs.lshw
  ];

  boot.extraModulePackages = [
    (config.boot.kernelPackages.rtl8192eu.overrideAttrs (old: {
      # Set flags specific to Raspberry Pi.
      makeFlags =
        (old.makeFlags or [])
        ++ [
          "CONFIG_PLATFORM_I386_PC=n"
          "CONFIG_PLATFORM_ARM_RPI=y"
        ];

      src = old.src.override {
        rev = "7ef82518547dcb5aacd8797e370332337b37d601";
        sha256 = "sha256-HK4VYEfe7tcXxQBqQ9reaOypubkKVRqa6zyNaQUhlxQ=";
      };

      meta.broken = false;
    }))
  ];

  boot.blacklistedKernelModules = [
    "rtl8xxxu"
  ];
}
