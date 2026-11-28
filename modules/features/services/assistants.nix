# Grok and Claude. nixasus lists this. The packages are unfree.
{
  flake.modules.nixos."assistants" = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.grok-build
      pkgs.claude-code
    ];
  };
}
