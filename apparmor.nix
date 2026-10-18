#apparmor.nix

{ config, pkgs, lib, ... }:

{
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = false;
}
