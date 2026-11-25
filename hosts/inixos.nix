#hosts/inixos.nix

{ config, pkgs, lib, ... }:

{
  imports = [
    ../cinnamon.nix
    ../nextcloud.nix
  ];

  networking.hostName = "inixos";

  # Sign John in when LightDM starts. The greeter does not ask for a password.
  services.displayManager.autoLogin = {
    enable = true;
    user = "John";
  };

  # Cinnamon does not start a login screen on its own.
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "cinnamon";
}
