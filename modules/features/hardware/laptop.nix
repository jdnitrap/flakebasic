# Lid, power profiles, firmware updates, and SSD trim.
{
  flake.modules.nixos."laptop" =
  { config, pkgs, lib, ... }:

  {

    services.fstrim.enable = true;
    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;

    nix.optimise.automatic = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";
    };

  }
;
}
