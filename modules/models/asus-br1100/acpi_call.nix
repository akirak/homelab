{config, ...}: {
  boot.kernelModules = ["acpi_call"];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];
}
