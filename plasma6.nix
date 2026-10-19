#plasma6.nix

{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  # GDM from gnome.nix is the login screen. It can start Plasma too.
  services.desktopManager.plasma6.enable = true;

  services.gvfs.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  xdg.terminal-exec.enable = true;
}
