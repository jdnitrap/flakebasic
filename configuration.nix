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

  # LightDM starts GNOME. The module picks the GTK greeter.
  services.xserver.displayManager.lightdm.enable = true;

  # GNOME stays the default login session.
  services.displayManager.defaultSession = lib.mkForce "gnome";

  # GNOME gets the SSH password prompt.
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

}
