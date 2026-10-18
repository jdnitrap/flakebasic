{
  description = "NixOS configurations by hostname";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      hosts = [ "Asus" "minilap" ];
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hosts/${hostName}.nix
          ];
        });
    };
}
