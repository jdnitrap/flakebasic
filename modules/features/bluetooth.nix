# Bluetooth hardware. Blueman is not turned on.
{
  flake.modules.nixos."bluetooth" = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
