#hardware-support.nix

{ config, pkgs, lib, ... }:

{

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

}
