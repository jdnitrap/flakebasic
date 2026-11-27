# NixOS state version. Do not change this on a computer that is already installed.
# This is not the Nixpkgs channel. The channel is the nixpkgs line in flake.nix.
{
  flake.modules.nixos."state-version" = {
    system.stateVersion = "26.05";
  };
}
