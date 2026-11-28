# Programs installed on every computer, and permission for unfree packages.
{
  flake.modules.nixos."packages" =
  {config, pkgs, lib, ...}:

  {

    # Grok and Claude are unfree. This allows them on the computer that lists assistants.
    nixpkgs.config.allowUnfree = true;

  
    environment.systemPackages = with pkgs; [

  	git
  	gnome-software
  	gh
  	flatpak
  	wireguard-tools

  	];



  }
;
}
