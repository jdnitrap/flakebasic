# Tailscale client. nixasus adds SSH and DNS flags in nixasus-tailscale.nix.
# inixos publishes Nextcloud and OnlyOffice from modules/features/services/nextcloud.nix.
{
  flake.modules.nixos."tailscale" = {
    services.tailscale.enable = true;
    services.tailscale.openFirewall = true;
  };
}
