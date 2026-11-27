# Lets every feature file add a NixOS module under the same list.
# Without this, Nix would refuse to combine those files.
{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    description = "NixOS modules collected from the feature files.";
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.deferredModule);
    default = { };
  };
}
