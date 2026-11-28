# Loose mode keeps a VPN working. Packets that match no route are still dropped.
{
  flake.modules.nixos."loose-reverse-path" = {
    networking.firewall.checkReversePath = "loose";
  };
}
