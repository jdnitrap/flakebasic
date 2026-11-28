# xserver installs XTerm and its launcher unless it is excluded.
{
  flake.modules.nixos."nixasus-desktop" = { pkgs, ... }: {
    services.xserver.excludePackages = [ pkgs.xterm ];
  };
}
