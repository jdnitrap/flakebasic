#hosts/Asus.nix

{ config, pkgs, lib, ... }:

{
  imports = [ ../hardware-configuration.nix ];

  networking.hostName = "Asus";
}
