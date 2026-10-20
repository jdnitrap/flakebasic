#configuration.nix

{ config, pkgs, lib, ... }:

{

##############  
#Module Setup#
##############

imports =
    [

	./hardware-support.nix
	./printer-scanner.nix
	./system-setup.nix
	./sound.nix
	./state-version.nix
	./system-packages.nix
	./gnome.nix
	./cinnamon.nix
	./plasma6.nix
	./boot.nix
	./networking.nix
	./user-accounts.nix
	./flatpak.nix
	./auto-update.nix
	./experimental-features.nix
	./laptop.nix
	./apparmor.nix
	./apparmor-gui.nix
	./auto-login.nix

    ];

  # Hostname and hardware stay in hosts/<name>.nix.

  # LightDM starts GNOME, Cinnamon, and Plasma.
  services.displayManager.lightdm.enable = true;
  services.displayManager.lightdm.greeters.gtk.enable = true;

  # GNOME and Cinnamon both set this. Empty wins so the build can finish.
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "";

  # Plasma would otherwise become the default login session.
  services.displayManager.defaultSession = lib.mkForce "gnome";

  # Plasma and GNOME both want the SSH password prompt.
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

}
