#hosts/inixos.nix

{ config, pkgs, lib, ... }:

{
  imports = [
    ../cinnamon.nix
    ../nextcloud.nix
  ];

  networking.hostName = "inixos";

  # Cinnamon does not start a login screen on its own.
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "cinnamon";
}
