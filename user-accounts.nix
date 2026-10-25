#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{

users.users."nimda" = {
    isNormalUser = true;
    description = "nimda";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

users.users."user1" = {
    isNormalUser = true;
    description = "user1";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
  };

}
