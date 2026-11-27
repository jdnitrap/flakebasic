{
  description = "NixOS for nixasus, minilap, and inixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Loads every file under modules/ as one configuration.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";
    # Newest stable release. A newer tag is adopted by updating this pin.
    hermes-agent.url = "github:NousResearch/hermes-agent/v0.23.4";
  };

  # flake.nix only names the inputs. The computers and features live in modules/.
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree ./modules
    );
}
