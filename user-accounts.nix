#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{

users.users."user1" = {
    isNormalUser = true;
    description = "user1";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
  };

}
