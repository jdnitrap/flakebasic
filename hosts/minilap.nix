#hosts/minilap.nix

{ config, pkgs, lib, ... }:

{
  imports = [ ./minilap-hardware.nix ];

  networking.hostName = "minilap";
}
