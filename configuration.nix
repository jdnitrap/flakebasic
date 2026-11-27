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
	./boot.nix
	./networking.nix
	./user-accounts.nix
	./flatpak.nix
#	./auto-update.nix
	./experimental-features.nix
	./laptop.nix
#	./apparmor.nix
#	./auto-login.nix
#	./adguard.nix

    ];

  # Hostname stays in hosts/<name>.nix.
  # Disks come from /etc/nixos/hardware-configuration.nix on the computer
  # being built. nixos-rebuild needs --impure to read that file.
  # This default only lets the flake evaluate when that file is not visible.
  # The generated file sets the same option without mkDefault and replaces it.
  fileSystems."/" = lib.mkDefault {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  # Desktop stays in the host file. Nextcloud is only imported by inixos.

  # The window comes from github:jdnitrap/apparmor-gui.
 # services.apparmor-gui.enable = true;

}
