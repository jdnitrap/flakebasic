#bootloader.nix

{config, pkgs, lib, ...}:

{

	# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Splash after the generation menu. Hides the boot text.
  boot.plymouth.enable = true;

}
