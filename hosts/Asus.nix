#hosts/Asus.nix

{ config, pkgs, lib, ... }:

{
  imports = [ ../gnome.nix ];

  networking.hostName = "Asus";
}
