# Facts that belong to this iMac and not to the other computers.
{
  flake.modules.nixos."inixos-host" =
  { lib, ... }:

  {
    # The account on this machine is already uid 1001.
    users.users.John.uid = lib.mkForce 1001;

    # Cinnamon does not provide Blueman. This machine uses it.
    services.blueman.enable = true;
  };
}
