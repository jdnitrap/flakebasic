# Turn on the Nix flakes commands.
{
  flake.modules.nixos."flakes" =
  { config, pkgs, lib, ... }:

  {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  }
;
}
