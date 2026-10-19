#cinnamon.nix

{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  # GDM from gnome.nix is the login screen. It can start Cinnamon too.
  services.xserver.desktopManager.cinnamon.enable = true;

  services.gvfs.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.cinnamon = {
      default = [ "gtk" ];
    };
  };

  xdg.terminal-exec.enable = true;
}
