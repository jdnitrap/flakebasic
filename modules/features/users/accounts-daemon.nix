# Account service. No computer uses this until a host lists it.
{
  flake.modules.nixos."accounts-daemon" =
  { config, pkgs, lib, ... }:

  {
    services.accounts-daemon.enable = true;
    users.mutableUsers = true;
  }
;
}
