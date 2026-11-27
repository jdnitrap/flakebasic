# Cinnamon does not start a login screen on its own.
{
  flake.modules.nixos."lightdm" = {
    services.xserver.displayManager.lightdm.enable = true;
    services.displayManager.defaultSession = "cinnamon";
  };
}
