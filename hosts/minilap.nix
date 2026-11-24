#hosts/minilap.nix

{ config, pkgs, lib, ... }:

{
  imports = [ ../gnome.nix ];

  networking.hostName = "minilap";
}
