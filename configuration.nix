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
	./boot.nix
	./networking.nix
	./user-accounts.nix
	./flatpak.nix
	./auto-update.nix
	./experimental-features.nix
	./laptop.nix
	./apparmor.nix
	./auto-login.nix

    ];

  # Hostname and hardware stay in hosts/<name>.nix.

  # GNOME and Cinnamon both set this. Empty wins so the build can finish.
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "";

}
