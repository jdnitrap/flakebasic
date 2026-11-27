# Lets the flake evaluate on a machine that has no hardware file yet.
# The generated hardware file replaces this when you rebuild with --impure.
{
  flake.modules.nixos."fallback-root" = { lib, ... }: {
    fileSystems."/" = lib.mkDefault {
      device = "tmpfs";
      fsType = "tmpfs";
    };
  };
}
